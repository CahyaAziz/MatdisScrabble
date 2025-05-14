extends Control
@onready var main_button: VBoxContainer = $MainButton
@onready var options: Panel = $Options
@onready var mulai_menu: Panel = $Mulai_menu
@onready var line_edit = get_node("Mulai_menu/TextureRect/LineEdit")
@onready var warning_label: Label = $Mulai_menu/TextureRect/LineEdit/warning_label

@onready var menu_click: AudioStreamPlayer = $MenuClick


func _Mulai():
	line_edit.grab_focus()

func _on_mulai_pressed():
	menu_click.play()
	var input_nama = line_edit.text.strip_edges()
	if input_nama == "":
		warning_label.text = "Masukkan nama terlebih dahulu!"
		warning_label.visible = true
	else:
		Global.username = input_nama
		get_tree().change_scene_to_file("res://scenes/game.tscn")

func _process(delta):
	pass
func _on_nama_changed(new_text: String):
	warning_label.visible = false

func _ready():
	line_edit.text_changed.connect(_on_nama_changed)
	Global.muat_histori()

	
func go_menu():
	menu_click.play()
	main_button.visible = true
	options.visible = false
	mulai_menu.visible = false

func _on_start_pressed() -> void:
	menu_click.play()
	print ("Login_pressed")
	main_button.visible = false
	mulai_menu.visible = true



func _on_setting_pressed() -> void:
	menu_click.play()
	print ("Setting_pressed")
	main_button.visible = false
	options.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_options_pressed() -> void:
	menu_click.play()
	go_menu()


func _on_music_value_changed(value: float) -> void:
	pass # Replace with function body.
	

func _on_back_pressed() -> void:
	menu_click.play()
	go_menu()


func _on_History_pressed() -> void:
	menu_click.play()
	get_tree().change_scene_to_file("res://Scenes/Score_Screen.tscn")
