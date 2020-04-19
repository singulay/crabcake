extends KinematicBody2D

var hp = 100
var movement_speed = 200

var attack_time = 0.1
var attack_timer
var attack_timeout = 0.5
var last_attack = 0

var block_time = 0.4
var block_timer
var block_timeout = 0.2
var last_block = 0
var can_block = true
var blocked = false

var throw_timer = 0
var throw_time = 0.8


var items = []
var active_state = ["default"]
var passive_state = ["default"]
var allowed_active_states = ["default", "attack", "block"]
var allowed_passive_states = ["default", "damage", "dead", "throw"]
var velocity = Vector2()
enum {north, east, south, west}

var face = east

var health = 100

var dir = Vector2()
var throw_acc = 0
var throw_strength = 250
export var deacc = 400

var damage_timer = 0
var damage_time = 0.3

var can_attack = true

var faces = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]

signal screen_shake
signal block_success

signal attack_hit(pos)

signal player_death

func enter(state):
	match state:
		"attack":
			velocity = Vector2()
			#$sprite.animation = "attack" + str(face)
			last_attack = attack_timeout
			attack_timer = attack_time
			emit_signal("attack_hit", position + faces[face])
		"block":
			velocity = Vector2()
			$sprite.animation = "block" + str(face)
			last_block = block_timeout
			block_timer = block_time
		"throw":
			$sprite.animation = "default"
			throw_timer = throw_time
			velocity = -dir*throw_strength
			emit_signal("screen_shake")
		"damage":
			damage_timer = damage_time
			#emit_signal("screen_shake")
func leave(state):
	match state:
		"attack":
			pass
		"block":
			block_timer = 0
			blocked = false
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
		"block":
			block_timer -= delta
			if block_timer <= 0 or blocked or not Input.is_action_pressed("block"):
				pop_active()
		"default":
			if last_attack >= 0:
				last_attack -= delta
			if last_block >= 0:
				last_block -= delta


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
			$sprite.modulate = Color(1, 1, 1, 1)
			if not Input.is_action_pressed("block"):
				can_block = true
			if not Input.is_action_pressed("attack"):
				can_attack = true
			if active_state[0] == "default":
				get_input()
				if Input.is_action_pressed("attack"):
					if last_attack <= 0 and can_attack: # check if timeout is over
						push_active("attack")
						can_attack = false
				if Input.is_action_pressed("block"):
					if last_block <= 0 and can_block:
						can_block = false
						push_active("block")
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				if collision.collider.name == "crab" and not get_parent().get_node("crab").dead:
					dir = (collision.collider.position - position).normalized()
					#print(collision.collider.position)
					if active_state[0] != "block":
						push_passive("damage")
						hp -= 10
						push_passive("throw")
					else:
						if dir.x > 0 and face == east:
							blocked = true
							emit_signal("block_success")
						elif dir.x < 0 and face == west:
							blocked = true
							emit_signal("block_success")
						else:
							blocked = false
							hp -= 10
							push_passive("damage")
							push_passive("throw")
		"throw":
			$sprite.modulate = Color(1, 1, 1, 1)
			throw_timer -= delta
			velocity -= velocity.normalized()*delta*deacc
			if throw_timer <= 0:
				pop_passive()
				
		"damage":
			if fmod(stepify(damage_timer, 0.1)*10, 2) == 0:
				
				$sprite.modulate = Color(0, 0, 0, 0)
			else:
				$sprite.modulate = Color(1, 1, 1, 1)
			if not Input.is_action_pressed("block"):
				can_block = true
			damage_timer -= delta
			if damage_timer <= 0:
				pop_passive()
			if active_state[0] == "default":
				get_input()
				if Input.is_action_pressed("attack"):
					if last_attack <= 0 and can_attack: # check if timeout is over
						push_active("attack")
						can_attack = false
				if Input.is_action_pressed("block"):
					if last_block <= 0 and can_block:
						can_block = false
						push_active("block")
					
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
	var set = false
	if Input.is_action_pressed('ui_right'):
		face = east
		set = true
		velocity.x += 1
	if Input.is_action_pressed('ui_left'):
		face = west
		set = true
		velocity.x -= 1
	if Input.is_action_pressed('ui_down'):
		velocity.y += 1
		if not set:
			face = south
	if Input.is_action_pressed('ui_up'):
		velocity.y -= 1
		if not set:
			face = north
			
	velocity = velocity.normalized() * movement_speed
	if velocity.length() > 0:

		$sprite.animation = "walk" + str(face)
	else:
		$sprite.animation = "idle" + str(face)	

	

func _ready():
	pass



func _physics_process(delta):
	move_and_slide(velocity)
	execute_active(delta)
	execute_passive(delta)
	if hp <= 0:
		emit_signal("player_death")


func _on_crab_spawn_attack(pos):

	if (position-pos).length() < 50:
		if passive_state[0] == "default":
			if active_state[0] != "block":
				hp -= 10
				push_passive("damage")
				emit_signal("screen_shake")
			else: # rework this!
				if (position-pos).y < 0 and face == south:
					blocked = true
					emit_signal("block_success")
				elif (position-pos).y > 0 and face == north:
					blocked = true
					emit_signal("block_success")
				else:
					hp -= 10
					push_passive("damage")
					emit_signal("screen_shake")



func _on_crab_heavy_attack(rect):
	if rect.has_point(position):
		if passive_state[0] == "default":
			hp -= 25
			push_passive("damage")
			push_passive("throw")

func _on_potion_heal():
	hp += 15
