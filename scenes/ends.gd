extends Control
@onready var winner: Label = $Winner
@onready var skor: Label = $Skor
@onready var menu_click: AudioStreamPlayer = $MenuClick

func _ready():
	winner.text = Global.username
	skor.text = str(Global.score)
	Global.histori.insert(0, {
		"nama": Global.username,
		"skor": Global.score,
		"waktu": Global.sisa_waktu
	})
	
	# Batas maksimal 10 entri
	if Global.histori.size() > 10:
		Global.histori = Global.histori.slice(0, 10)

	# Simpan ke file
	Global.simpan_histori()

func _on_button_pressed() -> void:
	menu_click.play()
	get_tree().change_scene_to_file("res://scenes/Main_Menu.tscn")
