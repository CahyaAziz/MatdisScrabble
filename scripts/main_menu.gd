extends Control
@onready var main_button: VBoxContainer = $MainButton
@onready var options: Panel = $Options
@onready var mulai_menu: Panel = $Mulai_menu
@onready var line_edit = get_node("Mulai_menu/TextureRect/LineEdit")

func _Mulai():
	line_edit.grab_focus()

func _on_mulai_pressed():
	Global.username = line_edit.text
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _process(delta):
	pass

func _ready() -> void:
	pass
	
func go_menu():
	main_button.visible = true
	options.visible = false
	mulai_menu.visible = false

func _on_start_pressed() -> void:
	print ("Login_pressed")
	main_button.visible = false
	mulai_menu.visible = true


func _on_setting_pressed() -> void:
	print ("Setting_pressed")
	main_button.visible = false
	options.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_options_pressed() -> void:
	go_menu()


func _on_music_value_changed(value: float) -> void:
	pass # Replace with function body.
	

func _on_back_pressed() -> void:
	go_menu()
