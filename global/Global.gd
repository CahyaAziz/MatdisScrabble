extends Node

var username: String = ""
var score: int = 0
var sisa_waktu: int = 0  # waktu dalam detik

var histori = [] # Menyimpan daftar histori

const SAVE_PATH = "user://histori.json"

# Simpan histori ke file JSON
func simpan_histori():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(histori))
		file.close()

# Muat histori dari file JSON
func muat_histori():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var data = file.get_as_text()
			var result = JSON.parse_string(data)
			if typeof(result) == TYPE_ARRAY:
				histori = result
			file.close()



var is_first_move = true

var turn = 3
var board = {}

var player_hand = []

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
