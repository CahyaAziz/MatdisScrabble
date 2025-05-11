extends Node2D
@onready var nama: Label = $TopUI/HBoxContainer2/Panel/TextureRect/Nama
@onready var timer: Timer = $Timer
@onready var label: Label = $Label
@onready var total_time_seconds : int = 600


func _ready():
	nama.text = Global.username
	$Timer.start()


func _on_timer_timeout():
	print(total_time_seconds)
	total_time_seconds -= 1
	var m = int (total_time_seconds/60)
	var s = total_time_seconds - m * 60
	
	if (total_time_seconds == 1440):
		total_time_seconds = 0
	$Label.text = '%02d:%02d' % [m,s]
	
