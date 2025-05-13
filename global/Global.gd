# Global.gd
extends Node
var username = ""

var is_first_move = true

var board = {}

var player_hand = []
var player_bag = [
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
