extends Node2D


func _ready():
	pass


func _input(event):
	if event is InputEventKey and event.pressed:
		get_tree().change_scene("res://game.tscn")
	if event is InputEventJoypadButton and event.pressed:
			get_tree().change_scene("res://Level/Level.tscn")
