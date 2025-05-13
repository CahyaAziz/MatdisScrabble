extends Node2D

signal hovered
signal hovered_off
# Add a new signal for selection in swap mode
signal tile_selected(tile)

var current_slot = null
var hand_pos
var letter = ""  # This is now required
var is_selected = false  # Track selection state

func _ready() -> void:
	get_parent().connect_tile_signal(self)
	
	# Make sure the Area2D is set up to detect input events
	if has_node("Area2D"):
		var area = get_node("Area2D")
		# Set the Area2D to detect input
		area.input_pickable = true
		
		# Connect the existing signals if they're not already connected
		if !area.is_connected("mouse_entered", _on_area_2d_mouse_entered):
			area.mouse_entered.connect(_on_area_2d_mouse_entered)
		if !area.is_connected("mouse_exited", _on_area_2d_mouse_exited):
			area.mouse_exited.connect(_on_area_2d_mouse_exited)

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
	
func lock():
	$Area2D/CollisionShape2D.disabled = true
	modulate = Color(0.8, 0.8, 0.8)  # Optional: Visually indicate it's locked

# Add a method to toggle selection state
func toggle_selection():
	is_selected = !is_selected
	if has_node("SelectionIndicator"):
		$SelectionIndicator.visible = is_selected
	return is_selected
