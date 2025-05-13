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
var original_tile_positions = {}

func _ready():
	# Connect the swap button signal
	if swap_button:
		if !swap_button.is_connected("pressed", _on_swap_button_pressed):
			swap_button.pressed.connect(_on_swap_button_pressed)
		print("Swap button connected successfully")
	else:
		print("ERROR: Swap button not found!")

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
			var distance = mouse_pos.distance_to(tile.global_position)
			print("Tile ", tile.letter, " at distance ", distance)
			
			if distance < closest_distance:
				closest_tile = tile
				closest_distance = distance
		
		if closest_tile:
			print("Selected tile: ", closest_tile.letter)
			toggle_tile_selection(closest_tile)

func _on_swap_button_pressed():
	print("Swap button pressed, current mode: ", is_swap_mode)
	
	if is_swap_mode:
		# If already in swap mode and pressed again, perform the swap
		perform_swap()
	else:
		# Enter swap mode
		enter_swap_mode()

func enter_swap_mode():
	print("Entering swap mode")
	is_swap_mode = true
	
	# Visual indicator for swap button being "held down"
	swap_button.modulate = Color(0.7, 0.7, 1.0)  # Change color to indicate active state
	
	# Disable other buttons
	others_button.disabled = true
	submit_button.disabled = true
	reset_button.disabled = true
	bag_button.disabled = true
	
	# Store original tile positions
	original_tile_positions.clear()
	for tile in Global.player_hand:
		original_tile_positions[tile] = tile.position
	
	# Completely disable the tile manager
	if tile_manager:
		# Save the original state
		tile_manager.set_meta("original_process", tile_manager.is_processing())
		tile_manager.set_meta("original_input", tile_manager.is_processing_input())
		
		# Disable processing
		tile_manager.set_process(false)
		tile_manager.set_process_input(false)
		
		# Disable all Area2D collision shapes in the tile manager
		for child in tile_manager.get_children():
			if child.has_node("Area2D"):
				var area = child.get_node("Area2D")
				if area.has_node("CollisionShape2D"):
					area.get_node("CollisionShape2D").disabled = true
	
	# Add selection indicators to all tiles
	for tile in Global.player_hand:
		if !tile.has_node("SelectionIndicator"):
			var indicator = ColorRect.new()
			indicator.name = "SelectionIndicator"
			indicator.color = Color(0.2, 0.8, 0.2, 0.5)  # Semi-transparent green
			indicator.size = Vector2(60, 60)  # Match tile size
			indicator.position = Vector2(-30, -30)  # Center on tile
			indicator.z_index = -1  # Place behind the tile
			indicator.visible = false
			tile.add_child(indicator)
	
	# Clear any previously selected tiles
	selected_tiles.clear()

func exit_swap_mode():
	print("Exiting swap mode")
	is_swap_mode = false
	
	# Restore swap button visual
	swap_button.modulate = Color(1, 1, 1)  # Reset to normal color
	
	# Re-enable other buttons
	others_button.disabled = false
	submit_button.disabled = false
	reset_button.disabled = false
	bag_button.disabled = false
	
	# Restore tile manager state
	if tile_manager:
		# Restore original processing state
		if tile_manager.has_meta("original_process"):
			tile_manager.set_process(tile_manager.get_meta("original_process"))
		if tile_manager.has_meta("original_input"):
			tile_manager.set_process_input(tile_manager.get_meta("original_input"))
		
		# Re-enable all Area2D collision shapes
		for child in tile_manager.get_children():
			if child.has_node("Area2D"):
				var area = child.get_node("Area2D")
				if area.has_node("CollisionShape2D"):
					area.get_node("CollisionShape2D").disabled = false
	
	# Clear selection visuals
	for tile in Global.player_hand:
		if tile.has_node("SelectionIndicator"):
			tile.get_node("SelectionIndicator").visible = false
	
	# Clear selected tiles array
	selected_tiles.clear()

# Update the toggle_tile_selection function in swap_manager.gd

func toggle_tile_selection(tile):
	print("Toggling selection for tile: ", tile.letter)
	
	if tile in selected_tiles:
		# Deselect tile
		selected_tiles.erase(tile)
		
		# Make sure the indicator is removed and recreated to avoid any issues
		if tile.has_node("SelectionIndicator"):
			tile.get_node("SelectionIndicator").queue_free()
		
		print("Tile deselected")
	else:
		# Select tile
		selected_tiles.append(tile)
		
		# Remove any existing indicator
		if tile.has_node("SelectionIndicator"):
			tile.get_node("SelectionIndicator").queue_free()
		
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
	bag.draw_tiles(selected_tiles.size())
	
	# Update hand positions
	player_hand.update_hand_positions()
	
	# Exit swap mode
	exit_swap_mode()
	
	# Reduces turn
	Global.turn -= 1
	print(Global.turn)
	turns_value.text = str(Global.turn)
	if Global.turn == 0:
		get_tree().change_scene_to_file("res://scenes/Ends.tscn")
	elif Global.turn == 1:
		swap_button.disabled = true
