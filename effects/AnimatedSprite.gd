extends AnimatedSprite


func _ready():
	pass


func _on_cracks_animation_finished():
	queue_free()
