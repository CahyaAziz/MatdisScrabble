extends Node2D

const collision_mask_tile = 1

var tile_drag
var screen_size

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
				tile_drag = tile
		else:
			tile_drag = null

func raycast_check():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = collision_mask_tile
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null


	
