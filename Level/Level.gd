extends Node2D

var level_min_x = -600
var level_min_y = -600
var level_max_x = 600
var level_max_y = 600

const potion = preload("res://objects/potion.tscn")
var potion_count = 0

const potion_positions = [Vector2(50, 50), Vector2(150, 150)]
var taken_potions = []

func spawn_potion(pos):
	var pot = potion.instance()
	pot.connect("heal", $player, "_on_potion_heal")
	pot.connect("heal", self, "_on_potion_heal")
	pot.position = pos
	add_child(pot)
	potion_count += 1
	
func _ready():
	spawn_potion(Vector2(50, 50))
	
func _on_potion_heal():
	potion_count -= 1

func _process(delta):
	
	pass


func _on_player_player_death():
	get_tree().paused = true
	print("Game Over.")


func _on_crab_crab_death():
	get_tree().paused = true
	print("Game Won.")


func _on_flower_flower_death():
	get_tree().paused = true
	print("Game Over.")


func _on_potiontimer_timeout():
	var i = randi()%2
	if i == 0:
		var pos = potion_positions[randi()%potion_positions.size()]
		if not (pos in taken_potions):
			taken_potions.append(pos)
			spawn_potion(pos)
