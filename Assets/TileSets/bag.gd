extends Node2D

const TILE_SCENE = "res://Assets/TileSets/scene/tile.tscn"



var tile_database_ref

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	tile_database_ref = "res://scripts/TileDatabase.gd"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func draw_tiles(n):
	
	if Global.player_bag.size() == 0:
		print("Bag empty")
		return
	
	if Global.player_hand.size() >= 7:
		print("Hand full")
		return
	
	var tile_scene = preload(TILE_SCENE)
	for i in range(n):
		var tile_name = Global.player_bag[0]
		print(tile_name)
		var new_tile = tile_scene.instantiate()
		var tile_image_path = str("res://Assets/TileSets/" + tile_name + "_Tile.svg")
		new_tile.get_node("Sprite2D").texture = load(tile_image_path)
		$"../TileManager".add_child(new_tile)
		new_tile.name = "Tile"
		$"../PlayerHand".add_tile_hand(new_tile)
		Global.player_bag.erase(Global.player_bag[0])
		
		
	
