extends Node2D

var occupied_tile = null

func is_occupied() -> bool:
	return occupied_tile != null

func assign_tile(tile):
	occupied_tile = tile

func remove_tile():
	occupied_tile = null
