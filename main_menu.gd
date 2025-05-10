extends Control
@onready var main_button: VBoxContainer = $MainButton
@onready var options: Panel = $Options

func _process(delta):
	pass

func _ready():
	main_button.visible = true
	options.visible = false

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")

func _on_setting_pressed() -> void:
	print ("Setting_pressed")
	main_button.visible = false
	options.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_options_pressed() -> void:
	_ready()
