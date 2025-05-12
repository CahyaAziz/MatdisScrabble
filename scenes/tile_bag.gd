extends Node2D

var tile_bag = ["A", "A", "A", "A", "A", "A", "A", "A", "A", "A"]  # Just 5 A's for now

const TILE_SCENE_PATH = "res://Assets/TileSets/scene/tile.tscn"

func draw_tile():
	if tile_bag.is_empty():
		return null

	var index = randi() % tile_bag.size()
	var letter = tile_bag[index]
	tile_bag.remove_at(index)

	var tile_scene = preload(TILE_SCENE_PATH)
	var tile = tile_scene.instantiate()
	tile.tile_type = letter
	return tile

func return_tile(letter: String):
	tile_bag.append(letter)
