extends Node2D

var level_min_x = -600
var level_min_y = -600
var level_max_x = 600
var level_max_y = 600

var flower_hp
var flower_step
const potion = preload("res://objects/potion.tscn")
var potion_count = 0

var won = false
var gameover = false

const f0 = preload("res://sprites/flower_bar_Animation 1_0.png")
const f1 = preload("res://sprites/flower_bar_Animation 1_1.png")
const f2 = preload("res://sprites/flower_bar_Animation 1_2.png")
const f3 = preload("res://sprites/flower_bar_Animation 1_3.png")
const f4 = preload("res://sprites/flower_bar_Animation 1_4.png")
const f5 = preload("res://sprites/flower_bar_Animation 1_5.png")
var flowers = [f0, f1, f2, f3, f4, f5]

const potion_positions = [Vector2(50, 50), Vector2(150, 150)]
var taken_potions = []

func get_flower_status():
	if $flower.hp >= flower_hp - flower_step:
		return 0
	if $flower.hp >= flower_hp - 2*flower_step:
		return 1
	if $flower.hp >= flower_hp - 3*flower_step:
		return 2
	if $flower.hp >= flower_hp - 4*flower_step:
		return 3
	if $flower.hp > flower_hp - 5*flower_step:
		return 4
	else:
		return 5

func spawn_potion(pos):
	var pot = potion.instance()
	pot.connect("heal", $player, "_on_potion_heal")
	pot.connect("heal", self, "_on_potion_heal")
	pot.connect("heal", $heal, "_on_potion_heal")
	pot.position = pos
	add_child(pot)
	potion_count += 1
	
func _ready():
	spawn_potion(Vector2(50, 50))
	$overlay.get_node("hpbar/hbox/gauge").max_value = $player.max_hp
	$overlay.get_node("crabbar/hbox/gauge").max_value = $crab.max_hp
	flower_hp = $flower.max_hp
	flower_step = flower_hp/5
	
func _on_potion_heal():
	potion_count -= 1
	
func _process(delta):
	$overlay.get_node("hpbar/hbox/gauge").value = $player.display_hp
	$overlay.get_node("crabbar/hbox/gauge").value = $crab.display_hp
	
	$overlay.get_node("crabbar/hbox/frame/flower").texture = flowers[get_flower_status()]

func gameover():
	$gameover.start()
	print("Game Over.")
	
func win():
	$gamewin.start()
	print("You win.")

func _on_player_player_death():
	if not gameover:
		gameover = true
		gameover()


func _on_crab_crab_death():
	if not won:
		won = true
		win()


func _on_flower_flower_death():
	if not gameover:
		gameover = true
		gameover()


func _on_potiontimer_timeout():
	var i = randi()%2
	if i == 0:
		var pos = potion_positions[randi()%potion_positions.size()]
		taken_potions.append(pos)
		spawn_potion(pos)


func _on_gameover_timeout():
	get_tree().paused = true
	get_tree().change_scene("res://gameover.tscn")


func _on_gamewin_timeout():
	get_tree().paused = true
	get_tree().change_scene("res://win.tscn")
