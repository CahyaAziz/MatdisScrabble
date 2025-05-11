extends Node2D
@onready var nama: Label = $TopUI/HBoxContainer2/Panel/TextureRect/Nama
func _ready():
	nama.text = Global.username
