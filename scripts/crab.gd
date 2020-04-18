extends KinematicBody2D

var distance
var velocity = Vector2()
var movement_speed = 100
var animation_speed = 2.5
const texture1 = preload("res://sprites/crabbody.png")
const texture2 = preload("res://sprites/crabbody2.png")

const explosion = preload("res://effects/Explosion.tscn")
const cracks = preload("res://effects/cracks.tscn")

var state = ["idle"]
var allowed_states = ["attack", "walk", "idle"]

var flipped = false

var attacks = ["attack1", "attack2", "double attack"]
var attacks2 = ["attack1u", "attack2u", "double attacku"]
var attack_timeout = 0.1
var last_attack = 0

var goal = "player"
var updown = 1

signal screen_shake
	
func push(new_state):
	if new_state in allowed_states:
		if new_state != state[0]:
			state.push_front(new_state)
			enter(new_state)
			
	
func pop():
	if state.size() > 0:
		leave(state[0])
		state.pop_front()
		reenter(state[0])

func execute(delta):
	var current_state = state[0]
	match current_state:
		"idle":
			get_input()
			
			$AnimationPlayer.current_animation = "idle"
			$AnimationPlayer.playback_speed = animation_speed
			if last_attack >= 0:
				last_attack -= delta
				
			if distance.length() > 20:
				velocity = distance.normalized() * movement_speed
				push("walk")
			else:
				velocity = Vector2()
				if state[0] == "idle":
					if last_attack <= 0:
						push("attack")
				
		"walk":
			get_input()
			if last_attack >= 0:
				last_attack -= delta
				
			if distance.length() > 20:
				velocity = distance.normalized() * movement_speed
				if velocity.length() > 0:
					push("walk")
			else:
				velocity = Vector2()
			
			if velocity.x > 0:
				# move right
				$AnimationPlayer.current_animation = "walks"
				$AnimationPlayer.playback_speed = -1*animation_speed
			if velocity.x < 0:
				$AnimationPlayer.current_animation = "walks"
				$AnimationPlayer.playback_speed = animation_speed
			if velocity.length() == 0:
				pop()
			
			if velocity.y > 0 and distance.length() > 50:
				flip("down")
			elif velocity.y < 0 and distance.length() > 50:
				flip("up")
		"attack":
			velocity = Vector2()
			
func enter(new_state):
	match new_state:
		"attack":
			if updown > 0:
				if distance.length() < 30:

					$AnimationPlayer.current_animation = attacks[randi()%(attacks.size()-1)]
				if distance.length() < 20:

					$AnimationPlayer.current_animation = attacks[randi()%attacks.size()]#"attack1"
			else:
				$AnimationPlayer.current_animation = attacks2[randi()%attacks2.size()]
			last_attack = attack_timeout

func leave(old_state):
	match old_state:
		_:
			pass

func reenter(old_state):
	match old_state:
		_:
			pass


func _ready():
	pass

func get_input():
	#velocity = Vector2()
	
	distance = get_parent().get_node(goal).position - position - updown * Vector2(0, 40)
	#if Input.is_action_pressed('ui_right'):
	#	velocity.x += 1
	#if Input.is_action_pressed('ui_left'):
	#	velocity.x -= 1
	#if Input.is_action_pressed('ui_down'):
	#	velocity.y += 1
	#if Input.is_action_pressed('ui_up'):
	#	velocity.y -= 1
	
				
func _physics_process(delta):
	move_and_slide(velocity)
	
	execute(delta)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name in attacks:
		pop()
	elif anim_name in attacks2:
		pop()
	pass # Replace with function body.


func flip(direction):
	if direction == "up":
		if flipped:
			$body.texture = texture2
			updown = -1
			flipped = false
	elif direction == "down":
		if not flipped:
			$body.texture = texture1
			updown = 1
			flipped = true

func spawn_explosion(animation : String):
	var boom = explosion.instance()
	if animation == "attack1":
		boom.position = $crableg3.position + Vector2(0, 8)
		
	if animation == "attack2":
		boom.position = $crableg6.position + Vector2(0, 8)
			
	add_child(boom)

func spawn_cracks():
	var boom = cracks.instance()
	boom.position = $body.position + Vector2(0, 22)
	emit_signal("screen_shake")
	add_child(boom)
