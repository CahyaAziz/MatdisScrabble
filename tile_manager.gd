extends Node2D

const collision_mask_tile = 1
const collision_mask_slot = 2

var tile_drag
var screen_size
var is_hovering_on_tile

func _ready() -> void:
	screen_size = get_viewport_rect().size

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
		else:
			if tile_drag:
				finish_drag()

func start_drag(tile):
	tile_drag = tile
	tile.scale = Vector2(1, 1)

func finish_drag():
	tile_drag.scale = Vector2(1.05, 1.05)
	var tile_slot_found = raycast_check_slot()
	if tile_slot_found and not tile_slot_found.tile_in_slot:
		tile_drag.position = tile_slot_found.position
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
