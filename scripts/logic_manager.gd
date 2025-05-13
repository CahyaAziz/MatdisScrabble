extends Node
@onready var valid: Panel = $"../Valid"

var accepted_words = []
var previous_board := {}

func _ready():
	load_word_list()

func hide_warning():
	print("Mulai countdown...")
	await get_tree().create_timer(2).timeout
	print("Sembunyikan valid!")
	valid.visible = false


func get_previous_board() -> Dictionary:
	return previous_board

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
		hide_warning()
		return

	if Global.is_first_move:
		if not current_move.has(Vector2(7, 7)):
			print("❌ First move must cover the center tile (H8).")
			valid.visible = true
			hide_warning()
			return
	else:
		var connected = is_connected_to_existing(board, current_move)
		print("Connected to existing tiles: ", connected)
		
		if not connected:
			print("❌ New tiles must connect to existing tiles.")
			valid.visible = true
			hide_warning()
			return

	var words = []
	words += find_words(board, true)
	words += find_words(board, false)

	if words.size() == 0:
		print("⚠️ No complete words found. Add more tiles.")
		valid.visible = true
		return

	var invalid_words := []
	for word in words:
		if word not in accepted_words:
			invalid_words.append(word)

	if invalid_words.size() > 0:
		print("❌ Invalid words found: ", invalid_words)
		valid.visible = true
		hide_warning()
	else:
		print("✅ All words are valid!")
		Global.is_first_move = false
		
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

func find_words(board: Dictionary, horizontal: bool) -> Array:
	var found_words = []
	var checked := {}

	for pos in board.keys():
		if pos in checked:
			continue

		var word = ""
		var letters = []
		var start_pos = pos
		var dir = Vector2(0, 1) if horizontal else Vector2(1, 0)

		var p = pos
		while board.has(p - dir):
			p -= dir
		start_pos = p

		while board.has(p):
			letters.append(board[p])
			checked[p] = true
			p += dir

		if letters.size() > 1:
			word = "".join(letters)
			found_words.append(word)

	return found_words
