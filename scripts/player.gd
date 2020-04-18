extends KinematicBody2D

var hp = 100
var movement_speed = 200

var attack_time = 0.5
var attack_timer
var attack_timeout = 0.1
var last_attack = 0

var dodge_time = 0.5
var dodge_timer
var dodge_timeout = 0.2
var last_dodge = 0

var throw_timer = 0
var throw_time = 0.8

var items = []
var active_state = ["default"]
var passive_state = ["default"]
var allowed_active_states = ["default", "attack", "dodge"]
var allowed_passive_states = ["default", "damage", "dead", "throw"]
var velocity = Vector2()
enum {north, east, south, west}

var dir
var throw_acc = 0
var throw_strength = 250
export var deacc = 400

var damage_timer = 0
var damage_time = 0.8

signal screen_shake

func enter(state):
	match state:
		"attack":
			print("attack!")
			last_attack = attack_timeout
			attack_timer = attack_time
		"dodge":
			print("dodge!")
			last_dodge = dodge_timeout
			dodge_timer = dodge_time
		"throw":
			print("ahhhhh")
			throw_timer = throw_time
			velocity = -dir*throw_strength
			emit_signal("screen_shake")
		"damage":
			print("that's a lotta damage")
			damage_timer = damage_time
			#emit_signal("screen_shake")
func leave(state):
	match state:
		"attack":
			print("no longer attacking!")
		"dodge":
			print("no longer dodging!")
		_:
			pass

func reenter(state):
	match state:
		_:
			pass

func execute_active(delta):
	var state = active_state[0]
	match state:
		"attack":
			attack_timer -= delta
			if attack_timer <= 0:
				pop_active()
		"dodge":
			dodge_timer -= delta
			if dodge_timer <= 0:
				pop_active()
		"default":
			if last_attack >= 0:
				last_attack -= delta
			if last_dodge >= 0:
				last_dodge -= delta


func push_active(state):
	if state in allowed_active_states:
		if state != active_state[0]:
			active_state.push_front(state)
			enter(state)
			
	
func pop_active():
	if active_state.size() > 0:
		leave(active_state[0])
		active_state.pop_front()
		reenter(active_state[0])
		
func execute_passive(delta):
	var state = passive_state[0]
	match state:
		"default":
			get_input()
			if Input.is_action_pressed("attack"):
				if last_attack <= 0: # check if timeout is over
					push_active("attack")
			if Input.is_action_pressed("dodge"):
				if last_dodge <= 0:
					push_active("dodge")
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				if collision.collider.name == "crab":
					dir = (collision.collider.position - position).normalized()
					#print(collision.collider.position)
					push_passive("throw")
		"throw":
			throw_timer -= delta
			velocity -= velocity.normalized()*delta*deacc
			if throw_timer <= 0:
				pop_passive()
				push_passive("damage")	
		"damage":
			damage_timer -= delta
			if damage_timer <= 0:
				pop_passive()
			get_input()
			if Input.is_action_pressed("attack"):
				if last_attack <= 0: # check if timeout is over
					push_active("attack")
			if Input.is_action_pressed("dodge"):
				if last_dodge <= 0:
					push_active("dodge")
					
func push_passive(state):
	if state in allowed_passive_states:
		if state != passive_state[0]:
			passive_state.push_front(state)
			enter(state)
			
	
func pop_passive():
	if passive_state.size() > 0:
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
	
	move_and_slide(velocity)
	execute_active(delta)
	execute_passive(delta)
	
