extends Node

# References to UI elements
@onready var others_button = $"../GameplayButton/HBoxContainer/Other"
@onready var swap_button = $"../GameplayButton/HBoxContainer/Swap"
@onready var submit_button = $"../GameplayButton/HBoxContainer/Submit"
@onready var reset_button = $"../GameplayButton/HBoxContainer/Reset"
@onready var bag_button = $"../GameplayButton/HBoxContainer/Bag"
@onready var turns_value: Label = $"../TopUI/HBoxContainer/MoveInfo/TurnsValue"


# References to game systems
@onready var player_hand = $"../PlayerHand"
@onready var bag = $"../Bag"
@onready var tile_manager = $"../TileManager"

# State tracking
var is_swap_mode = false
var selected_tiles = []

# Track mouse position for tile detection
var last_mouse_position = Vector2.ZERO

func _ready():
	# Connect the swap button signal
	if swap_button:
		if !swap_button.is_connected("pressed", _on_swap_button_pressed):
			swap_button.pressed.connect(_on_swap_button_pressed)
		print("Swap button connected successfully")
	else:
		print("ERROR: Swap button not found!")
	
	# Connect the reset button signal
	if reset_button:
		if !reset_button.is_connected("pressed", _on_reset_button_pressed):
			reset_button.pressed.connect(_on_reset_button_pressed)
		print("Reset button connected successfully")
	else:
		print("ERROR: Reset button not found!")
	
	# Initialize selection indicators for all tiles
	for tile in Global.player_hand:
		if is_instance_valid(tile) and !tile.has_node("SelectionIndicator"):
			var indicator = ColorRect.new()
			indicator.name = "SelectionIndicator"
			indicator.color = Color(0.2, 0.8, 0.2, 0.5)  # Semi-transparent green
			indicator.size = Vector2(60, 60)  # Match tile size
			indicator.position = Vector2(-30, -30)  # Center on tile
			indicator.z_index = -1  # Place behind the tile
			indicator.visible = false
			tile.add_child(indicator)

func _process(delta):
	# Emergency exit
	if Input.is_action_just_pressed("ui_cancel") and is_swap_mode:
		print("Emergency exit from swap mode")
		exit_swap_mode()
	
	# Handle tile selection in swap mode
	if is_swap_mode and Input.is_action_just_pressed("ui_select"):  # Left mouse click
		var mouse_pos = get_viewport().get_mouse_position()
		var tile = find_tile_at_position(mouse_pos)
		if tile:
			toggle_tile_selection(tile)
	
	# Disable swap button when only one turn left
	if swap_button and is_instance_valid(swap_button):
		swap_button.disabled = (Global.turn <= 1)

func _input(event):
	if !is_swap_mode:
		return
		
	# Handle direct mouse clicks for tile selection
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		print("Mouse clicked at: ", mouse_pos)
		
		# Simple distance-based detection
		var closest_tile = null
		var closest_distance = 100.0  # Maximum detection distance
		
		for tile in Global.player_hand:
			if !is_instance_valid(tile):
				continue
				
			var distance = mouse_pos.distance_to(tile.global_position)
			print("Tile ", tile.letter, " at distance ", distance)
			
			if distance < closest_distance:
				closest_tile = tile
				closest_distance = distance
		
		if closest_tile:
			print("Selected tile: ", closest_tile.letter)
			toggle_tile_selection(closest_tile)

func find_tile_at_position(position):
	# Simple distance-based detection
	var closest_tile = null
	var closest_distance = 100.0  # Maximum detection distance
	
	for tile in Global.player_hand:
		if !is_instance_valid(tile):
			continue
			
		var distance = position.distance_to(tile.global_position)
		
		if distance < closest_distance:
			closest_tile = tile
			closest_distance = distance
	
	return closest_tile

func _on_swap_button_pressed():
	print("Swap button pressed, current mode: ", is_swap_mode)
	
	if is_swap_mode:
		# If already in swap mode and pressed again, perform the swap
		perform_swap()
	else:
		# Enter swap mode
		enter_swap_mode()

func _on_reset_button_pressed():
	print("Reset button pressed, retrieving tiles from board")
	retrieve_tiles_from_board()

func retrieve_tiles_from_board():
	# Find all tile slots with tiles that are not locked
	var tile_slots = get_tree().get_nodes_in_group("tile_slots")
	var tiles_to_retrieve = []
	
	for slot in tile_slots:
		if slot.is_occupied() and slot.occupied_tile and is_instance_valid(slot.occupied_tile):
			var tile = slot.occupied_tile
			
			# Check if the tile is valid and has the required node
			if is_instance_valid(tile) and tile.has_node("Area2D") and tile.get_node("Area2D").has_node("CollisionShape2D"):
				var collision = tile.get_node("Area2D/CollisionShape2D")
				
				# Check if the collision shape is not disabled (tile is not locked)
				if !collision.disabled:
					tiles_to_retrieve.append({"tile": tile, "slot": slot})
	
	print("Found ", tiles_to_retrieve.size(), " tiles to retrieve")
	
	# Return tiles to hand
	for item in tiles_to_retrieve:
		var tile = item["tile"]
		var slot = item["slot"]
		
		# Double check that the tile is still valid
		if is_instance_valid(tile) and is_instance_valid(slot):
			# Remove from slot
			slot.remove_tile()
			
			# Add back to hand if not already there and still valid
			if is_instance_valid(tile) and tile not in Global.player_hand:
				Global.player_hand.append(tile)
	
	# Update hand positions if player_hand is valid
	if is_instance_valid(player_hand):
		player_hand.update_hand_positions()

func enter_swap_mode():
	print("Entering swap mode")
	is_swap_mode = true
	
	# Visual indicator for swap button being "held down"
	if swap_button and is_instance_valid(swap_button):
		swap_button.modulate = Color(0.7, 0.7, 1.0)  # Change color to indicate active state
	
	# Disable other buttons
	if others_button and is_instance_valid(others_button):
		others_button.disabled = true
	if submit_button and is_instance_valid(submit_button):
		submit_button.disabled = true
	if reset_button and is_instance_valid(reset_button):
		reset_button.disabled = true
	if bag_button and is_instance_valid(bag_button):
		bag_button.disabled = true
	
	# Retrieve any tiles from the board first
	retrieve_tiles_from_board()
	
	# Disable tile dragging
	disable_tile_dragging()
	
	# Clear any previously selected tiles
	selected_tiles.clear()
	
	# Clear ALL selection visuals to start fresh
	for tile in Global.player_hand:
		if is_instance_valid(tile):
			remove_selection_indicators(tile)

func exit_swap_mode():
	print("Exiting swap mode")
	is_swap_mode = false
	
	# Restore swap button visual
	if swap_button and is_instance_valid(swap_button):
		swap_button.modulate = Color(1, 1, 1)  # Reset to normal color
	
	# Re-enable other buttons
	if others_button and is_instance_valid(others_button):
		others_button.disabled = false
	if submit_button and is_instance_valid(submit_button):
		submit_button.disabled = false
	if reset_button and is_instance_valid(reset_button):
		reset_button.disabled = false
	if bag_button and is_instance_valid(bag_button):
		bag_button.disabled = false
	
	# Re-enable tile dragging
	enable_tile_dragging()
	
	# Clear selection visuals - more thorough approach
	for tile in Global.player_hand:
		if is_instance_valid(tile):
			remove_selection_indicators(tile)
	
	# Clear selected tiles array
	selected_tiles.clear()

func disable_tile_dragging():
	# Disable the tile manager's ability to drag tiles
	if tile_manager and is_instance_valid(tile_manager):
		tile_manager.set_process(false)
		tile_manager.set_process_input(false)

func enable_tile_dragging():
	# Re-enable the tile manager's ability to drag tiles
	if tile_manager and is_instance_valid(tile_manager):
		tile_manager.set_process(true)
		tile_manager.set_process_input(true)

func remove_selection_indicators(tile):
	# Check if the tile is valid
	if !is_instance_valid(tile):
		return
		
	# Find and remove ALL nodes with "SelectionIndicator" in their name
	var children = tile.get_children()
	for i in range(children.size() - 1, -1, -1):  # Loop backwards to safely remove
		var child = children[i]
		if is_instance_valid(child) and "SelectionIndicator" in child.name:
			child.queue_free()

func toggle_tile_selection(tile):
	# Check if the tile is valid
	if !is_instance_valid(tile):
		print("Invalid tile, cannot toggle selection")
		return
		
	print("Toggling selection for tile: ", tile.letter)
	
	if tile in selected_tiles:
		# Deselect tile
		selected_tiles.erase(tile)
		
		# Properly remove ALL selection indicators
		remove_selection_indicators(tile)
		
		print("Tile deselected")
	else:
		# Select tile
		selected_tiles.append(tile)
		
		# Remove any existing indicators first
		remove_selection_indicators(tile)
		
		# Create a new indicator with proper settings
		var indicator = ColorRect.new()
		indicator.name = "SelectionIndicator"
		indicator.color = Color(0.2, 0.8, 0.2, 0.7)  # More opaque green
		indicator.size = Vector2(60, 60)  # Match tile size
		indicator.position = Vector2(-30, -30)  # Center on tile
		indicator.z_index = 10  # Make sure it's above the tile
		indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block mouse events
		tile.add_child(indicator)
		
		print("Tile selected, indicator added")

func perform_swap():
	print("Performing swap with ", selected_tiles.size(), " tiles")
	
	if selected_tiles.size() == 0:
		# Nothing to swap, just exit swap mode
		print("No tiles selected, exiting swap mode")
		exit_swap_mode()
		return
	
	# Return selected tiles to the bag
	for tile in selected_tiles:
		# Check if the tile is still valid
		if !is_instance_valid(tile):
			continue
			
		# Add the letter back to the bag
		Global.player_bag.append(tile.letter)
		print("Returning ", tile.letter, " to bag")
		
		# Remove from hand
		Global.player_hand.erase(tile)
		
		# Remove from scene
		tile.queue_free()
	
	# Shuffle the bag
	Global.player_bag.shuffle()
	
	# Draw new tiles
	if bag and is_instance_valid(bag):
		bag.draw_tiles(selected_tiles.size())
	
	# Update hand positions
	if player_hand and is_instance_valid(player_hand):
		player_hand.update_hand_positions()
	
	# Exit swap mode
	exit_swap_mode()
	
	# Reduces turn
	Global.turn -= 1
	print(Global.turn)
	turns_value.text = str(Global.turn)
