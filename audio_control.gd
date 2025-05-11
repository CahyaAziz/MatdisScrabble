extends HSlider

@export var audio_bus_name:String

var audio_bus_id

func _ready():
	var bus_index = AudioServer.get_bus_index(audio_bus_name)
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

	
func _on_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	var bus_index = AudioServer.get_bus_index(audio_bus_name)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),linear_to_db(value))


func _on_mouse_exited() -> void:
	release_focus()
