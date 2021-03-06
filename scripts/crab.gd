extends KinematicBody2D

var distance
var flower_distance
var player_distance
var damage_taken = 0
var velocity = Vector2()
var movement_speed = 100
var animation_speed = 2.5

var dmg = 10

const texture1 = preload("res://sprites/spr_cbody.png")
const texture2 = preload("res://sprites/spr_cbodyb.png")

const explosion = preload("res://effects/Explosion.tscn")
const cracks = preload("res://effects/cracks.tscn")

var wait_timer = 0
var wait_time = 0.5


var flower
var flower_dist


var state = ["idle"]
var allowed_states = ["attack", "walk", "idle", "throw", "dead"]

var max_hp = 200
var hp = max_hp
var display_hp = hp
var hp_speed = 30

var dead = false
var flipped = false



var attacks = ["attack1", "attack2", "double_attack"]
var attacks2 = ["attack1u", "attack2u", "double_attacku"]
var attack_timeout = 0.5
var last_attack = 0
var attack_timer = 0

var heavy_cooldown = 1
var heavy_timer = 0

var goal = "player"
var updown = 1
var flip_time = 0.3
var flip_timer = 0
signal screen_shake
signal spawn_attack(pos)
signal heavy_attack(rect)
var throw_force = 250
var throw_timer = 0
var throw_time = 1.2
var dir
var deacc = 400

var damage_timer = 0
var damage_time = 0.2

signal crab_death

func push(new_state):
	if new_state in allowed_states:
		if new_state != state[0]:
			state.push_front(new_state)
			enter(new_state)
			
	
func pop():
	if state.size() > 1:
		leave(state[0])
		state.pop_front()
		reenter(state[0])

func execute(delta):
	var current_state = state[0]
	match current_state:
		"dead":
			velocity = Vector2()
			if $AnimationPlayer.current_animation in  ["walks", "idle", "throw"]:
				$AnimationPlayer.current_animation = "death"
		"idle":
			if display_hp <= 0:
				pop()
				pop()
				push("dead")
			get_input()
			
			if damage_timer >= 0:
				damage_timer -= delta
			if display_hp > 0:
				$AnimationPlayer.current_animation = "idle"
			$AnimationPlayer.playback_speed = animation_speed
			if last_attack >= 0:
				last_attack -= delta
			if heavy_timer >= 0:
				heavy_timer -= delta
			if wait_timer <= 0:
				if distance.length() > 20:
					velocity = distance.normalized() * movement_speed
					push("walk")
				else:
					velocity = Vector2()
					if state[0] == "idle":
						if last_attack <= 0:
							push("attack")
				
		"walk":
			if damage_timer >= 0:
				damage_timer -= delta
			
			if display_hp <= 0:
				pop()
				pop()
				velocity = Vector2()
				push("dead")
			if display_hp > 0:
				get_input()
			if last_attack >= 0:
				last_attack -= delta
			if heavy_timer >= 0:
				heavy_timer -= delta	
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
			
			if velocity.y > 0 and distance.length() > 30:
				flip("down", delta)
			elif velocity.y < 0 and distance.length() > 30:
				flip("up", delta)
		"attack":
			if display_hp <= 0:
				pop()
				pop()
				push("dead")
			if damage_timer >= 0:
				damage_timer -= delta
			attack_timer -= delta
			if attack_timer <= 0:
				#pop()
				pass
			velocity = Vector2()
		
		"throw":
			if display_hp <= 0:
				pop()
				pop()
				push("dead")
			if damage_timer >= 0:
				damage_timer -= delta
			$AnimationPlayer.current_animation = "idle"
			velocity -= velocity.normalized()*delta*deacc
			throw_timer -= delta
			if throw_timer <= 0:
				pop()
				
func enter(new_state):
	match new_state:
		"attack":
			if last_attack <= 0:
				if updown > 0:
					if distance.length() < 30 and distance.length() > 25:
						$AnimationPlayer.current_animation = attacks[randi()%(attacks2.size()-1)]
					if distance.length() <= 25:
						var att
						if heavy_timer <= 0:
							att = randi()%attacks.size()
						else:
							att = randi()%(attacks.size()-1)
						if att == 2:
							heavy_timer = heavy_cooldown
							attack_timer = 2
						$AnimationPlayer.current_animation = attacks[att]#"attack1"
				else:
					if distance.length() < 30 and distance.length() > 25:
						$AnimationPlayer.current_animation = attacks2[randi()%(attacks2.size()-1)]
					if distance.length() <= 25:
						var att
						if heavy_timer <= 0:
							att = randi()%attacks2.size()
						else:
							att = randi()%(attacks2.size()-1)
						if att == 2:
							heavy_timer = heavy_cooldown
							attack_timer = 2
						$AnimationPlayer.current_animation = attacks2[att]#"attack1"
					
					
				last_attack = attack_timeout
		"throw":
			throw_timer = throw_time
			dir = (position - get_parent().get_node("player").position).normalized()
			velocity = dir * throw_force
		"dead":
			$AnimationPlayer.current_animation = "death"
			visible = true
			dead = true
			$deadtime.start()
			
func leave(old_state):
	match old_state:
		"throw":
			pass
		_:
			pass

func reenter(old_state):
	match old_state:
		_:
			pass


func _ready():
	flower = get_parent().get_node("flower")
	pass

func get_input():
	#velocity = Vector2()
	
	
	flower_distance = flower.position - position - updown * Vector2(0, 10)
	player_distance = get_parent().get_node("player").position - position - updown * Vector2(0, 25)
	
	if state[0] != "dead":
		if goal in ["corner0", "corner1", "corner2", "corner3"]:
			if damage_taken > 0:
				goal = "player"
			if player_distance.length() > 100:
				var k = randi()%3
				if k == 0:
					goal = "flower"
				else:
					goal = "player"
		if goal == "player":
			var i = randi()%100
			if i == 0:
				goal = "corner" + str(randi()%4)
				damage_taken = 0
			if player_distance.length() > 100:
				goal = "flower"
				damage_taken = 0
		if goal == "flower":
			var i = randi()%100
			if i == 0:
				damage_taken = 0
				goal = "corner" + str(randi()%4)

			if damage_taken >= 20:
				goal = "player"
				pop()
				wait_timer = wait_time
			if player_distance.length() < 60:
				var j = randi()%10
				if j == 0:
					goal = "player"
			
		distance = get_parent().get_node(goal).position - position - updown * Vector2(0, 25)
	#if Input.is_action_pressed('ui_right'):
	#	velocity.x += 1
	#if Input.is_action_pressed('ui_left'):
	#	velocity.x -= 1
	#if Input.is_action_pressed('ui_down'):
	#	velocity.y += 1
	#if Input.is_action_pressed('ui_up'):
	#	velocity.y -= 1
	
func attack1_audio():
	$attack1.play()
func attack2_audio():
	$attack2.play()
				
func _physics_process(delta):
	if hp <= 0:
		push("dead")
	if display_hp != hp:
		display_hp -= delta*hp_speed*sign(display_hp - hp)
	if wait_timer > 0:
		wait_timer -= delta
	move_and_slide(velocity)
	if not dead:
		
		if damage_timer > 0:
			if fmod(stepify(damage_timer, 0.1)*10, 2) == 0:
				
				visible = false
			else:
				visible = true
		else:
			visible = true

	execute(delta)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name in attacks:
		if state[0] == "attack":
			
			pop()
	elif anim_name in attacks2:
		if state[0] == "attack":
			pop()
	if anim_name == "death":
		emit_signal("crab_death")

func flip(direction, delta):
	if flip_timer <= 0:
		flip_timer = flip_time
		if direction == "up":
			if flipped:
				$body.texture = texture2
				updown = -1
				$claw1.visible = false
				$claw2.visible = false
				$claw3.visible = true
				$claw4.visible = true
				$crableg1.visible = false
				$crableg4.visible = false
				$crableg7.visible = true
				$crableg8.visible = true
				flipped = false
		elif direction == "down":
			if not flipped:
				$body.texture = texture1
				updown = 1
				$claw1.visible = true
				$claw2.visible = true
				$claw3.visible = false
				$claw4.visible = false
				$crableg1.visible = true
				$crableg4.visible = true
				$crableg7.visible = false
				$crableg8.visible = false
				flipped = true
	flip_timer -= delta

func spawn_explosion(animation : String):
	var boom = explosion.instance()
	if animation == "attack1":
		boom.position = $claw1.position + Vector2(0, 8)
		
	if animation == "attack2":
		boom.position = $claw2.position + Vector2(0, 8)
		
	if animation == "attack1u":
		boom.position = $claw3.position + Vector2(0, -8)
	
	if animation == "attack2u":
		boom.position = $claw4.position + Vector2(0, -8)	
	emit_signal("spawn_attack", boom.position + position)		
	add_child(boom)

func spawn_cracks():
	var boom = cracks.instance()
	boom.position = $body.position + updown * Vector2(0, 22)
	emit_signal("screen_shake")
	emit_signal("heavy_attack", Rect2(position.x-21, position.y, 42, 60))		
	add_child(boom)


func _on_player_block_success():
	pop()
	push("throw")
	pass # Replace with function body.


func _on_player_attack_hit(pos):
	
	if state[0] == "idle" or state[0] == "attack" or state[0] == "walk" or state[0] == "throw":
		if (pos - position).length() < 65:
			damage_timer = damage_time
			hp -= dmg
			$damage.play()
			damage_taken += dmg
		


func _on_deadtime_timeout():
	emit_signal("crab_death")

func death_sound():
	$death.play()
