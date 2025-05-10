extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")


func _on_setting_pressed() -> void:
	print ("Setting_pressed")


func _on_exit_pressed() -> void:
	get_tree().quit()
