extends Node2D
@onready var game_scene: Node2D = $"."
@onready var nama: Label = $TopUI/HBoxContainer2/Panel/TextureRect/Nama
@onready var timer: Timer = $Timer
@onready var label: Label = $Label
@onready var total_time_seconds : int = 60*10
@onready var bag: Node2D = $Bag
@onready var bag_2: Panel = $Bag2
@onready var turns_value: Label = $TopUI/HBoxContainer/MoveInfo/TurnsValue
@onready var swap_manager = $SwapManager

var bag_ref

var game_reset = null

func _ready():
	# Your existing code...
	nama.text = Global.username
	turns_value.text = str(Global.turn)
	timer.start()
	bag_ref = $Bag
	
	# Reset game state
	if !has_node("GameReset"):
		var game_reset_script = load("res://scripts/game_reset.gd")
		var game_reset_node = Node.new()
		game_reset_node.name = "GameReset"
		game_reset_node.set_script(game_reset_script)
		add_child(game_reset_node)
		game_reset = game_reset_node
	
	# Call the reset function
	if game_reset:
		game_reset.reset_game_state()
		
	Global.player_bag.shuffle()
	$Bag.debug_draw_tiles(["N","A","D","A", "K", "A", "N"])
	
	# Initialize the swap manager
	if !has_node("SwapManager"):
		var swap_manager_scene = load("res://scenes/swap_manager.gd")
		var swap_manager_node = Node.new()
		swap_manager_node.name = "SwapManager"
		swap_manager_node.set_script(swap_manager_scene)
		add_child(swap_manager_node)
		swap_manager = swap_manager_node
		print("Swap manager initialized")

func _on_timer_timeout():
	total_time_seconds -= 1
	var m = int(total_time_seconds / 60)
	var s = total_time_seconds % 60
	
	label.text = '%02d:%02d' % [m, s]
	
	# Ketika waktu habis, pindah ke scene "ends.tscn"
	if total_time_seconds <= 0:
		timer.stop()
		get_tree().change_scene_to_file("res://Scenes/Ends.tscn")

func bag_menu():
	bag_2.visible = true	

func go_menu():
	bag_2.visible = false
	game_scene.visible = true

func _on_button_pressed() -> void:
	go_menu()

func update_bag_counts():
	var letter_counts = {}

	# Hitung jumlah setiap huruf di player_bag, termasuk 'blank'
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

			# Tangani huruf biasa dan 'blank'
			if label_node and label_node is Label:
				# Kalau 'blank', ambil jumlah 'blank', lainnya seperti biasa
				if huruf == "blank":
					label_node.text = str(letter_counts.get("blank", 0))
				else:
					label_node.text = str(letter_counts.get(huruf, 0))



func _on_bag_pressed() -> void:
	update_bag_counts()
	bag_menu()
	
