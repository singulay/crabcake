extends StaticBody2D


var max_hp = 150
var hp = max_hp

signal flower_death
const sprite2 = preload("res://sprites/flower_dead.png")
func _ready():
	pass

func _process(delta):
	if hp <= 0:
		emit_signal("flower_death")
		$Sprite.texture = sprite2

func _on_crab_spawn_attack(pos):
	if (position - pos).length() < 50:
		hp -= 10


func _on_crab_heavy_attack(rect):
	if rect.has_point(position):
		hp -= 25
