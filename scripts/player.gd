extends KinematicBody2D

var hp = 100
var movement_speed = 50
var items = []
var active_state = ["default"]
var passive_state = ["default"]
var allowed_active_states = ["default", "attack", "dodge"]
var allowed_passive_states = ["default", "damage", "dead"]
var velocity
enum {north, east, south, west}


func enter(state):
	match state:
		_:
			pass

func leave(state):
	match state:
		_:
			pass

func reenter(state):
	match state:
		_:
			pass

func push_active(state):
	if state in allowed_active_states:
		if state != active_state[0]:
			active_state.push_front(state)
			enter(state)
			
	
func pop_active():
	if active_state.len() > 0:
		leave(active_state[0])
		active_state.pop_front()
		reenter(active_state[0])
		
func push_passive(state):
	if state in allowed_passive_states:
		if state != passive_state[0]:
			passive_state.push_front(state)
			enter(state)
			
	
func pop_passive():
	if passive_state.len() > 0:
		leave(passive_state[0])
		passive_state.pop_front()
		reenter(passive_state[0])

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
	if Input.is_action_pressed('ui_down'):
		velocity.y += 1
	if Input.is_action_pressed('ui_up'):
		velocity.y -= 1
	velocity = velocity.normalized() * movement_speed




func _ready():
	pass



func _physics_process(delta):
	get_input()
	move_and_slide(velocity)
