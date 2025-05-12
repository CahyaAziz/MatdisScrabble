extends Control
@onready var winner: Label = $Winner

func _ready():
	winner.text = Global.username


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main_Menu.tscn")
