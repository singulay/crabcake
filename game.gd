extends Node2D


func _ready():
	get_tree().paused = false
	pass
	
func _process(delta):
	pass

func _input(event):
	if event is InputEventKey and event.pressed:
			get_tree().change_scene("res://Level/Level.tscn")
