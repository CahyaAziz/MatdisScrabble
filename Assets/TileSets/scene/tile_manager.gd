extends Node2D

const collision_mask_tile = 1
const collision_mask_slot = 2
@onready var sfx_balok_star: AudioStreamPlayer = $"../sfx_balok_star"

var tile_drag
var screen_size
var is_hovering_on_tile
var player_hand_ref

func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_ref = $"../PlayerHand"

func _process(delta: float) -> void:
	if tile_drag:
		var mouse_pos = get_global_mouse_position()
		tile_drag.position = Vector2(clamp(mouse_pos.x, 50, screen_size.x - 50), 
		clamp(mouse_pos.y, 50, screen_size.y -50)) 

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var tile = raycast_check()
			if tile:
				start_drag(tile)
				sfx_balok_star.play()
		else:
			if tile_drag:
				finish_drag()
				sfx_balok_star.play()

func start_drag(tile):
	tile_drag = tile
	tile.scale = Vector2(1, 1)

	if tile.has_node("sfx_balok_star"):
		tile.get_node("sfx_balok_star").play()  # Suara saat balok diangkat


func finish_drag():
	tile_drag.scale = Vector2(1.05, 1.05)
	var new_slot = raycast_check_slot()

	if tile_drag.current_slot and is_instance_valid(tile_drag.current_slot):
		tile_drag.current_slot.remove_tile()
		tile_drag.current_slot = null

	if new_slot and not new_slot.is_occupied():
		tile_drag.position = new_slot.position
		new_slot.assign_tile(tile_drag)
		tile_drag.current_slot = new_slot

		# ✅ Suara saat balok ditaruh
		if tile_drag.has_node("sfx_balok_start"):
			tile_drag.get_node("sfx_balok_star").play()
	else:
		player_hand_ref.add_tile_hand(tile_drag)

	tile_drag = null


func connect_tile_signal(tile):
	tile.connect("hovered", on_hover_tile)
	tile.connect("hovered_off", off_hover_tile)

func on_hover_tile(tile):
	if !is_hovering_on_tile:
		is_hovering_on_tile = true
		highlight_tile(tile, true)
	

func off_hover_tile(tile):
	if !tile_drag:
		highlight_tile(tile, false)
		var new_card_hovered = raycast_check()
		if new_card_hovered:
			highlight_tile(new_card_hovered, true)
		else:
			is_hovering_on_tile = false
	
func highlight_tile(tile, hovered):
	if hovered:
		tile.scale = Vector2(1.05, 1.05)
		tile.z_index = 2
	else:
		tile.scale = Vector2(1, 1)
		tile.z_index = 1

func raycast_check_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = collision_mask_slot
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func raycast_check():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = collision_mask_tile
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_tile_highest_z(result)
	return null

func get_tile_highest_z(tile):
	var highest_z_tile = tile[0].collider.get_parent()
	var highest_z_index = highest_z_tile.z_index
	
	for i in range(1, tile.size()):
		var curr = tile[i].collider.get_parent()
		if curr.z_index > highest_z_index:
			highest_z_tile = curr
			highest_z_index = curr.z_index
	return highest_z_tile
