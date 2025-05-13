# game_reset.gd
extends Node

@onready var turns_value: Label = get_tree().get_current_scene().get_node("TopUI/HBoxContainer/MoveInfo/TurnsValue")
# This script handles resetting the game state when starting a new game

func reset_game_state():
	print("Resetting game state...")
	
	# Reset global variables
	Global.is_first_move = true
	Global.turn = 3  # Reset to default turn count
	Global.board = {}  # Clear the board state
	Global.score = 0
	turns_value.text = str(Global.turn)
	
	
	# Reset player hand
	for tile in Global.player_hand:
		if is_instance_valid(tile):
			tile.queue_free()
	Global.player_hand.clear()
	
	# Reset player bag (restore all tiles)
	Global.player_bag = [
		# 1-point letters
		'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A',
		'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A',
		'I', 'I', 'I', 'I', 'I', 'I', 'I', 'I', 'I', 'I',
		'I', 'I', 'I', 'I', 'I', 'I', 'I', 'I',
		'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N',
		'N', 'N', 'N', 'N', 'N', 'N', 'N',
		'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E',
		'E', 'E', 'E', 'E', 'E', 'E',
		'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U',
		'U', 'U', 'U', 'U', 'U',
		'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R', 'R',
		'R', 'R',
		'T', 'T', 'T', 'T', 'T', 'T', 'T', 'T', 'T', 'T',
		'T',
		
		# 2-point letters
		'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S',
		'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L',
		'O', 'O', 'O', 'O', 'O', 'O', 'O',
		'M', 'M', 'M', 'M', 'M', 'M',
		'K', 'K', 'K', 'K', 'K', 'K',
		'D', 'D', 'D', 'D', 'D',
		
		# 3-point letters
		'G', 'G', 'G', 'G', 'G',
		'B', 'B', 'B', 'B', 'B',
		'P', 'P', 'P', 'P',
		
		# 4-point letters
		'Y', 'Y', 'Y', 'Y',
		'H', 'H', 'H', 'H',
		
		# 5-point letters
		'C', 'C', 'C', 'C',
		'J', 'J',
		
		# 8-point letters
		'W', 'W',
		'Q',
		'V',
		
		# Blank tiles
		'blank', 'blank'
	]
	
	# Reset the logic manager's previous board state
	var logic_manager = get_node_or_null("/root/GameScene/LogicManager")
	if logic_manager and "previous_board" in logic_manager:
		logic_manager.previous_board = {}
	
	# Reset score
	if logic_manager and "score" in logic_manager:
		logic_manager.score = 0
		
		# Update score display
		if logic_manager.has_node("../TopUI/HBoxContainer/Score/ScoreValue"):
			logic_manager.get_node("../TopUI/HBoxContainer/Score/ScoreValue").text = "0"
	
	# Reset tile slots
	var tile_slots = get_tree().get_nodes_in_group("tile_slots")
	for slot in tile_slots:
		slot.remove_tile()
		slot.occupied_tile = null
	
	print("Game state reset complete")
