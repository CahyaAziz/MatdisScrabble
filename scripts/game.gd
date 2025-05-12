extends Node2D

@onready var nama: Label = $TopUI/HBoxContainer2/Panel/TextureRect/Nama
@onready var timer: Timer = $Timer
@onready var label: Label = $Label
@onready var total_time_seconds : int = 60*10
@onready var bag: Node2D = $Bag

var bag_ref

func _ready():
	nama.text = Global.username
	timer.start()
	bag_ref = $Bag
	Global.player_bag.shuffle()
	bag_ref.draw_tiles(7)	

func _on_timer_timeout():
	total_time_seconds -= 1
	var m = int(total_time_seconds / 60)
	var s = total_time_seconds % 60
	
	label.text = '%02d:%02d' % [m, s]
	
	# Ketika waktu habis, pindah ke scene "ends.tscn"
	if total_time_seconds <= 0:
		timer.stop()
		get_tree().change_scene_to_file("res://Scenes/Ends.tscn")


func _on_button_3_pressed() -> void:
	Global.player_bag.shuffle()
	bag_ref.draw_tiles(1)
