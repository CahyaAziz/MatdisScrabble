extends Node2D
@onready var game_scene: Node2D = $"."
@onready var nama: Label = $TopUI/HBoxContainer2/Panel/TextureRect/Nama
@onready var timer: Timer = $Timer
@onready var label: Label = $Label
@onready var total_time_seconds : int = 60*10
@onready var bag: Node2D = $Bag
@onready var bag_2: Panel = $Bag2

var bag_ref

func _ready():
	nama.text = Global.username
	timer.start()
	bag_ref = $Bag
	Global.player_bag.shuffle()
	$Bag.debug_draw_tiles(["N","A","D","A", "K", "A"])

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

func bag_menu():
	bag_2.visible = true	

func go_menu():
	bag_2.visible = false
	game_scene.visible = true

func _on_button_pressed() -> void:
	go_menu()

func update_bag_counts():
	var letter_counts = {}

	# Hitung jumlah setiap huruf di player_bag
	for letter in Global.player_bag:
		if not letter_counts.has(letter):
			letter_counts[letter] = 1
		else:
			letter_counts[letter] += 1

	# Ambil GridContainer di Bag2
	var grid = $Bag2/GridContainer
	
	for child in grid.get_children():
		if child.name.begins_with("Huruf_"):
			var huruf = child.name.replace("Huruf_", "")  # Misal: Huruf_A → A
			var label_node = child.get_node("Label_" + huruf)
			if label_node and label_node is Label:
				label_node.text = str(letter_counts.get(huruf, 0))


func _on_bag_pressed() -> void:
	update_bag_counts()
	bag_menu()
