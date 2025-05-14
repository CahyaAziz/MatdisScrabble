extends Node
@onready var valid: Panel = $"../Valid"
@onready var turns_value: Label = $"../TopUI/HBoxContainer/MoveInfo/TurnsValue"
@onready var definition: Panel = $"../Definition"
@onready var sfx_salah_start: AudioStreamPlayer = $"../sfx_salah_start"
@onready var sfx_benar_start: AudioStreamPlayer = $"../sfx_benar_start"

func play_benar_clip():
	sfx_benar_start.play()
	sfx_benar_start.seek(1.0)  # mulai dari detik ke-3
	await get_tree().create_timer(4.0).timeout  # tunggu 2 detik (sampai detik ke-5)
	sfx_benar_start.stop()

func play_salah_clip():
	sfx_salah_start.play()
	sfx_salah_start.seek(1.0)  # mulai dari detik ke-3
	await get_tree().create_timer(4.0).timeout  # tunggu 2 detik (sampai detik ke-5)
	sfx_salah_start.stop()

var bag_ref
var game_ref

var accepted_words = []
var previous_board := {}

var TileDB = preload("res://scripts/TileDatabase.gd")

var tiles_placed = 0

# Define the board multipliers
# DL = Double Letter, TL = Triple Letter, DW = Double Word, TW = Triple Word
var board_multipliers = {
	# Double Letter Score positions
	Vector2(0, 3): "DL", Vector2(0, 11): "DL",
	Vector2(2, 6): "DL", Vector2(2, 8): "DL",
	Vector2(3, 0): "DL", Vector2(3, 7): "DL", Vector2(3, 14): "DL",
	Vector2(6, 2): "DL", Vector2(6, 6): "DL", Vector2(6, 8): "DL", Vector2(6, 12): "DL",
	Vector2(7, 3): "DL", Vector2(7, 11): "DL",
	Vector2(8, 2): "DL", Vector2(8, 6): "DL", Vector2(8, 8): "DL", Vector2(8, 12): "DL",
	Vector2(11, 0): "DL", Vector2(11, 7): "DL", Vector2(11, 14): "DL",
	Vector2(12, 6): "DL", Vector2(12, 8): "DL",
	Vector2(14, 3): "DL", Vector2(14, 11): "DL",
	
	# Triple Letter Score positions
	Vector2(1, 5): "TL", Vector2(1, 9): "TL",
	Vector2(5, 1): "TL", Vector2(5, 5): "TL", Vector2(5, 9): "TL", Vector2(5, 13): "TL",
	Vector2(9, 1): "TL", Vector2(9, 5): "TL", Vector2(9, 9): "TL", Vector2(9, 13): "TL",
	Vector2(13, 5): "TL", Vector2(13, 9): "TL",
	
	# Double Word Score positions
	Vector2(1, 1): "DW", Vector2(1, 13): "DW",
	Vector2(2, 2): "DW", Vector2(2, 12): "DW",
	Vector2(3, 3): "DW", Vector2(3, 11): "DW",
	Vector2(4, 4): "DW", Vector2(4, 10): "DW",
	Vector2(10, 4): "DW", Vector2(10, 10): "DW",
	Vector2(11, 3): "DW", Vector2(11, 11): "DW",
	Vector2(12, 2): "DW", Vector2(12, 12): "DW",
	Vector2(13, 1): "DW", Vector2(13, 13): "DW",
	
	# Triple Word Score positions
	Vector2(0, 0): "TW", Vector2(0, 7): "TW", Vector2(0, 14): "TW",
	Vector2(7, 0): "TW", Vector2(7, 14): "TW",
	Vector2(14, 0): "TW", Vector2(14, 7): "TW", Vector2(14, 14): "TW",
	
	# Center tile (usually a Double Word Score)
	Vector2(7, 7): "DW"
}

@onready var score_value: Label = $"../TopUI/HBoxContainer/Score/ScoreValue"


func _ready():
	load_word_list()
	bag_ref = $"../Bag"
	game_ref = $".."

func hide_warning():
	print("Mulai countdown...")
	await get_tree().create_timer(2).timeout
	print("Sembunyikan valid!")
	valid.visible = false


func get_previous_board() -> Dictionary:
	return previous_board
	
func calculate_word_score(word_positions, board, new_tiles):
	var word_score = 0
	var word_multiplier = 1
	
	for pos in word_positions:
		var letter = board[pos]
		var letter_score = TileDB.TILES[letter][0]
		var letter_multiplier = 1
		
		# Only apply multipliers for new tiles
		if pos in new_tiles:
			# Check for letter multipliers
			if board_multipliers.has(pos):
				var multiplier_type = board_multipliers[pos]
				if multiplier_type == "DL":
					letter_multiplier = 2
				elif multiplier_type == "TL":
					letter_multiplier = 3
				elif multiplier_type == "DW":
					word_multiplier *= 2
				elif multiplier_type == "TW":
					word_multiplier *= 3
		
		word_score += letter_score * letter_multiplier
	
	# Apply word multiplier
	word_score *= word_multiplier
	
	return word_score

func are_new_tiles_connected(new_tiles: Dictionary) -> bool:
	if new_tiles.size() == 0:
		return false
	
	if new_tiles.size() == 1:
		return true
	
	print("Checking connectivity for new tiles: ", new_tiles.keys())
	
	var all_same_row = true
	var all_same_col = true
	var first_pos = new_tiles.keys()[0]
	var row = first_pos.x
	var col = first_pos.y
	
	for pos in new_tiles.keys():
		if pos.x != row:
			all_same_row = false
		if pos.y != col:
			all_same_col = false
	
	print("All same row: ", all_same_row, ", All same col: ", all_same_col)
	
	if all_same_row or all_same_col:
		var positions = new_tiles.keys()
		var min_pos
		var max_pos
		
		if all_same_row:
			positions.sort_custom(func(a, b): return a.y < b.y)
			min_pos = positions[0]
			max_pos = positions[positions.size() - 1]
			
			print("Horizontal line from ", min_pos, " to ", max_pos)
			
			for y in range(min_pos.y, max_pos.y + 1):
				var pos = Vector2(row, y)
				if not new_tiles.has(pos) and not previous_board.has(pos):
					print("Gap found at ", pos)
					return false
			
			print("No gaps found in horizontal line")
			return true
			
		elif all_same_col:
			positions.sort_custom(func(a, b): return a.x < b.x)
			min_pos = positions[0]
			max_pos = positions[positions.size() - 1]
			
			print("Vertical line from ", min_pos, " to ", max_pos)
			
			for x in range(min_pos.x, max_pos.x + 1):
				var pos = Vector2(x, col)
				if not new_tiles.has(pos) and not previous_board.has(pos):
					print("Gap found at ", pos)
					return false
			
			print("No gaps found in vertical line")
			return true
	
	print("Not in a straight line, using original connectivity check")
	
	var combined_board = previous_board.duplicate()
	for pos in new_tiles:
		combined_board[pos] = new_tiles[pos]
	
	var visited = {}
	var found_count = 0
	
	var start_pos = new_tiles.keys()[0]
	var to_visit = [start_pos]
	
	while to_visit.size() > 0:
		var pos = to_visit.pop_back()
		if pos in visited:
			continue
		
		visited[pos] = true
		
		if new_tiles.has(pos):
			found_count += 1
		
		for dir in [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]:
			var neighbor = pos + dir
			if combined_board.has(neighbor) and not visited.has(neighbor):
				to_visit.append(neighbor)
	
	print("Found ", found_count, " out of ", new_tiles.size(), " new tiles")
	return found_count == new_tiles.size()

func load_word_list():
	var file = FileAccess.open("res://accepted_words.txt", FileAccess.READ)
	while not file.eof_reached():
		var word = file.get_line().strip_edges().to_upper()
		if word != "":
			accepted_words.append(word)
	file.close()

func is_connected_to_existing(board: Dictionary, new_tiles: Dictionary) -> bool:
	if Global.is_first_move:
		return true
		
	for pos in new_tiles.keys():
		for dir in [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]:
			var neighbor = pos + dir
			if board.has(neighbor) and not new_tiles.has(neighbor):
				return true
	
	return false

func find_slot_by_pos(pos: Vector2) -> Node:
	var tile_slots := get_tree().get_nodes_in_group("tile_slots")
	for slot in tile_slots:
		if slot.row == pos.x and slot.col == pos.y:
			return slot
	return null


func _on_submit_pressed():
	var board := {}
	var tile_slots := get_tree().get_nodes_in_group("tile_slots")

	for slot in tile_slots:
		if slot.is_occupied():
			var letter = slot.occupied_tile.letter
			var pos = Vector2(slot.row, slot.col)
			board[pos] = letter

	var current_move := {}
	for pos in board.keys():
		if not get_previous_board().has(pos):
			current_move[pos] = board[pos]

	print("Current board: ", board)
	print("Previous board: ", get_previous_board())
	print("New tiles: ", current_move)

	if current_move.size() == 0:
		print("⚠️ No new tiles placed.")
		valid.visible = false  # <- jangan tampilkan peringatan
		return
		
	if not are_new_tiles_connected(current_move):
		print("❌ All new tiles must be connected in one group.")
		valid.visible = true
		play_salah_clip()
		hide_warning()
		return

	if Global.is_first_move:
		if not current_move.has(Vector2(7, 7)):
			print("❌ First move must cover the center tile (H8).")
			valid.visible = true
			play_salah_clip()
			hide_warning()
			return
	else:
		if not is_connected_to_existing(board, current_move):
			var connected = is_connected_to_existing(board, current_move)
			print("Connected to existing tiles: ", connected)
			
			if not connected:
				print("❌ New tiles must connect to existing tiles.")
				valid.visible = true
				play_salah_clip()
				hide_warning()
				return

	var words_horizontal = find_words(board, true)  # horizontal
	var words_vertical = find_words(board, false)   # vertical
	var all_words = words_horizontal + words_vertical
	
	# Filter words to only include those that contain at least one new tile
	var words_with_new_tiles = []
	for word_data in all_words:
		var contains_new_tile = false
		for pos in word_data["positions"]:
			if current_move.has(pos):
				contains_new_tile = true
				break
		
		if contains_new_tile:
			words_with_new_tiles.append(word_data)
	
	if words_with_new_tiles.size() == 0:
		print("⚠️ No complete words found. Add more tiles.")
		valid.visible = true
		sfx_salah_start.play()
		hide_warning()
		return
	
	var invalid_words := []
	var turn_score = 0
	var valid_words = []
	
	for word_data in words_with_new_tiles:  # Use filtered words
		var word = word_data["word"]
		if word not in accepted_words:
			invalid_words.append(word)
		else:
			# Calculate score for valid words
			var word_score = calculate_word_score(word_data["positions"], board, current_move)
			turn_score += word_score
			valid_words.append(word + " (" + str(word_score) + ")")
			print("Word: " + word + ", Score: " + str(word_score))
			if definition and definition.has_method("add_word_to_list"):
				definition.add_word_to_list(word)

	if invalid_words.size() > 0:
		print("❌ Invalid words found: ", invalid_words)
		valid.visible = true
		play_salah_clip()
		hide_warning()
	else:
		# Add bonus for using all 7 tiles
		if current_move.size() == 7:
			turn_score += 50
			print("Bonus for using all 7 tiles: +50")
			
		# Update total score
		Global.score += turn_score
		play_benar_clip()
		print("✅ All words are valid! Turn score: " + str(turn_score) + ", Total score: " + str(Global.score))
		print("Words formed: " + ", ".join(valid_words))
		
		# Update score display in the UI
		if score_value:
			score_value.text = str(Global.score)
		else:
			# Try to find the score label with a different path
			var nodes = get_tree().get_nodes_in_group("ScoreValue")
			if nodes.size() > 0:
				nodes[0].text = str(Global.score)
			else:
				print("Score label not found. Please add a Label node with the name 'Score' or add it to the 'score_label' group.")
		
		Global.is_first_move = false  # Only now toggle the flag
		
		previous_board = {}
		for pos in board:
			previous_board[pos] = board[pos]
		
		print("Updated previous_board: ", previous_board)
		
		for pos in current_move.keys():
			var slot = find_slot_by_pos(pos)
			if slot and slot.is_occupied():
				var tile = slot.occupied_tile
				tile.lock()
				Global.player_hand.erase(tile)
				tiles_placed += 1
		
		bag_ref.draw_tiles(tiles_placed)
		tiles_placed = 0
		Global.turn -= 1
		turns_value.text = str(Global.turn)
		if Global.turn == 0:
			game_ref.selesai_lebih_awal()
			get_tree().change_scene_to_file("res://scenes/Ends.tscn")


func find_words(board: Dictionary, horizontal: bool) -> Array:
	var found_words = []
	var checked := {}

	for pos in board.keys():
		if pos in checked:
			continue

		var letters = []
		var word_positions = []
		var start_pos = pos
		var dir = Vector2(0, 1) if horizontal else Vector2(1, 0)

		var p = pos
		while board.has(p - dir):
			p -= dir
		start_pos = p

		while board.has(p):
			letters.append(board[p])
			word_positions.append(p)
			checked[p] = true
			p += dir

		if letters.size() > 1:
			var word = "".join(letters)
			found_words.append({"word": word, "positions": word_positions})

	return found_words
