extends Control
func _ready():
	pass

func _proces(delta):
	pass
	

func _on_start_pressed() -> void:
	print ("Start pressed")


func _on_setting_pressed() -> void:
	print ("Setting_pressed")


func _on_exit_pressed() -> void:
	get_tree().quit()
