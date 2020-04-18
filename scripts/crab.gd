extends KinematicBody2D

var distance
var velocity = Vector2()
var movement_speed = 100
var animation_speed = 2.5

var state = ["idle"]
var allowed_states = ["attack", "walk", "idle"]

var attack_timeout = 0.1
var last_attack = 0


		
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
				if velocity.length() > 0:
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
		"attack":
			velocity = Vector2()
			
func enter(new_state):
	match new_state:
		"attack":
			$AnimationPlayer.current_animation = "attack1"
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
	
	distance = get_parent().get_node("player").position - position - Vector2(0, 40)
	#if Input.is_action_pressed('ui_right'):
	#	velocity.x += 1
	#if Input.is_action_pressed('ui_left'):
	#	velocity.x -= 1
	#if Input.is_action_pressed('ui_down'):
	#	velocity.y += 1
	#if Input.is_action_pressed('ui_up'):
	#	velocity.y -= 1
	
				
func _physics_process(delta):
	print($AnimationPlayer.current_animation)
	move_and_slide(velocity)
	print(state[0])
	execute(delta)


func _on_AnimationPlayer_animation_finished(anim_name):
	
	match anim_name:
		"attack1":
			pop()
	pass # Replace with function body.
