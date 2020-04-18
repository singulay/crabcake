extends Camera2D

var state = ["normal"]
var shake_timer = 0
var shake_time = 0.3
export var shake_magnitude : Vector2

func _ready():
	var lvl = get_parent()
	limit_left = lvl.level_min_x
	limit_top = lvl.level_min_y
	limit_right = lvl.level_max_x
	limit_bottom = lvl.level_max_y


func _process(delta):
	position = get_parent().get_node("player").position

	match state[0]:
		"shake":
			shake_timer -= delta
			if shake_timer <= 0:
				pop()
				offset = Vector2()
			offset = Vector2(rand_range(-shake_magnitude.x, shake_magnitude.x), rand_range(-shake_magnitude.y, shake_magnitude.y))	
	
func pop():
	if state.size() > 1:
		state.pop_front()
		
func push(new_state):
	if state[0] != new_state:
		state.push_front(new_state)
		match new_state:
			"shake":
				shake_timer = shake_time


func _on_player_screen_shake():

	push("shake")



func _on_crab_screen_shake():
	push("shake")
