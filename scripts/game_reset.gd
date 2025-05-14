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
	var player_bag = [
	'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A',  # 12 A's (-1)
	'B', 'B', 'B',  # 3 B's
	'C', 'C',  # 2 C's
	'D', 'D', 'D', 'D', 'D',  # 5 D's
	'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E',  # 9 E's (-1)
	'F',  # 1 F
	'G', 'G', 'G', 'G',  # 4 G's
	'H', 'H', 'H',  # 3 H's
	'I', 'I', 'I', 'I', 'I', 'I', 'I', 'I',  # 8 I's (-1)
	'J', 'J',  # 2 J's
	'K', 'K', 'K', 'K', 'K',  # 5 K's (-1)
	'L', 'L', 'L', 'L',  # 4 L's
	'M', 'M', 'M', 'M',  # 4 M's
	'N', 'N', 'N', 'N', 'N', 'N',  # 6 N's (-1)
	'O', 'O', 'O', 'O', 'O',  # 5 O's
	'P', 'P', 'P',  # 3 P's
	'Q',  # 1 Q
	'R', 'R', 'R', 'R', 'R',  # 5 R's (-1)
	'S', 'S', 'S', 'S',  # 4 S's
	'T', 'T', 'T', 'T',  # 5 T's (-1)
	'U', 'U', 'U', 'U',  # 4 U's
	'V',  # 1 V
	'W',  # 1 W
	'X',  # 1 X
	'Y', 'Y',  # 2 Y's
	'Z'   # 1 Z
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
