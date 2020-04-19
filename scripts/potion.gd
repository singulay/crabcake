extends Sprite

signal heal

func _ready():
	
	pass


func _on_Area2D_body_entered(body):
	if body.name == "player":
		emit_signal("heal")
		queue_free()
