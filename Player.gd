extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal death
signal level_complete
signal fire
signal end_fire
signal game_complete

const ping_velocity = 1000
const min_ping_velocity = 300
const jump_velocity = 400
const max_vel = 400
const max_y_vel = 800
const acceleration = 35
const friction = 20
const gravity = 20
const max_attachment_length = 5000
const angular_acceleration = 80

var velocity
var movement_mode
var is_still_jumping
var attachment_point

func reset(spawn_pos):
	position = spawn_pos
	velocity = Vector2()
	movement_mode = 'normal'
	is_still_jumping = false
	attachment_point = null
	$indicator.reset()

func _ready():
	#sm_rope()
	#sm_tween_proxy()
	reset(position)

func _process(delta):
	if position.y > 350:
		emit_signal('death')

func _physics_process(delta):
	
	if Input.is_action_just_released('jump'):
		is_still_jumping = false
	
	if Input.is_action_just_released('attach'):
		emit_signal('end_fire', false)
		is_still_jumping = false
	
	match movement_mode:
		'normal':
			normal_movement()
		'grabbed':
			grabbed_movement()
		'attached':
			attached_movement()

func attached_movement():
	if attachment_point == null:
		return
	
	var direction_to_attachment = (attachment_point - position).normalized()
	if (attachment_point - position).length():
		pass
	velocity += direction_to_attachment * angular_acceleration
		
func grabbed_movement():
	
	var axis = Vector2(Input.get_joy_axis(0, 0), Input.get_joy_axis(0, 1))
	
	$indicator/jump_target.position = axis * 75
	
	if Input.is_action_just_released('grab'):
		var jump_size = $indicator.charge * (ping_velocity - min_ping_velocity) + min_ping_velocity
		velocity = axis.normalized() * $indicator.jump()  * jump_size
		movement_mode = 'normal'
		$indicator.start_charge()
		
func normal_movement():
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if get_slide_count() > 0:
		for i in range(get_slide_count()):
			handle_collision(get_slide_collision(i))

	#jump
	if velocity.y < 0 and is_still_jumping:
		velocity.y += gravity / 2
	else:
		velocity.y += gravity
	
	#friction
	if abs(velocity.x) < friction:
		velocity.x = 0
	else:
		velocity.x -= sign(velocity.x) * friction
	
	if Input.is_action_pressed('move_left'):
		velocity.x -= acceleration
	
	if Input.is_action_pressed('move_right'):
		velocity.x += acceleration
	
	if abs(velocity.x) > max_vel:
		velocity.x = sign(velocity.x) * max_vel
	
	if abs(velocity.y) > max_y_vel:
		velocity.y = sign(velocity.y) * max_y_vel
		
	if Input.is_action_just_pressed('attach'):
		print('fire')
		emit_signal('fire')
	
	if Input.is_action_pressed('grab') and (is_on_wall() or is_on_floor() or is_on_ceiling()):
		$indicator.start_discharge()
		movement_mode = 'grabbed'
	
	if is_on_floor() and Input.is_action_just_pressed('jump'):
		is_still_jumping = true
		velocity.y -= jump_velocity
	
func handle_collision(collision):
	var other = collision.collider
	
	if other.name == 'finish':
		emit_signal('level_complete')
	
	if other.name == 'heart':
		emit_signal('game_complete')
	
	if other.is_in_group('enemy'):
		_collide_with_enemy(other)


func _collide_with_enemy(enemy):
	emit_signal('death')

func sm_rope():
	while true:
		yield(self, 'fire')
		$rope.show()
		var nearest_attachment
		if get_tree().has_group('attach'):
			for att in get_tree().get_nodes_in_group('attach'):
				if nearest_attachment == null or (att.position - position).length() < (nearest_attachment.position - position).length():
					nearest_attachment = att
		
		$Tween.interpolate_property($rope, 'endpoint', to_global(position), nearest_attachment.to_global(nearest_attachment.position), 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT)
		$Tween.start()
		var attached = yield(self, 'end_fire')
		print('endfire')
		if attached:
			print('attached')
			attachment_point = nearest_attachment.position
			movement_mode = 'attached'
		else:
			$Tween.stop($rope)
			$rope.reset()
		
		
		
func sm_tween_proxy():
	while true:
		yield($Tween, 'tween_completed')
		emit_signal('end_fire', true)
	
	
	
	
	