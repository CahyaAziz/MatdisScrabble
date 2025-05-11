extends Node2D

const HAND_COUNT = 5
const TILE_SCENE_PATH = "res://Assets/TileSets/scene/tile.tscn"
const TILE_WIDTH = 65
const HAND_Y_POS = 1290

# This is the left offset where your board starts from the screen's left edge
const BOARD_OFFSET_X = 806  # Adjust this to match the board's visible X start

var player_hand = []
var board_pixel_width = 15 * TILE_WIDTH  # Scrabble is 15x15 tiles

func _ready() -> void:
	var tile_scene = preload(TILE_SCENE_PATH)
	for i in range(HAND_COUNT):
		var new_tile = tile_scene.instantiate()
		$"../TileManager".add_child(new_tile)
		new_tile.name = "Tile"
		add_tile_hand(new_tile)

func add_tile_hand(tile):
	if tile not in player_hand:
		player_hand.append(tile)
		update_hand_positions()
	else:
		animate_to_pos(tile, tile.hand_pos)

func update_hand_positions():
	for i in range(player_hand.size()):
		var new_pos = Vector2(calc_tile_pos(i), HAND_Y_POS)
		var tile = player_hand[i]
		tile.hand_pos = new_pos
		animate_to_pos(tile, new_pos)

func calc_tile_pos(index):
	var total_width = (player_hand.size() - 1) * TILE_WIDTH
	var center_x = BOARD_OFFSET_X + board_pixel_width / 2
	var x_pos = center_x + index * TILE_WIDTH - total_width / 2
	return x_pos

func animate_to_pos(tile, new_pos):
	var tween = get_tree().create_tween()
	tween.tween_property(tile, "position", new_pos, 0.1)
	
func remove_tile_hand(tile):
	if tile in player_hand:
		player_hand.erase(tile)
		update_hand_positions()
