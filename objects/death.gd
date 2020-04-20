extends AudioStreamPlayer


func _ready():
	pass


func _on_player_player_death():
	print("ded")
	play()
