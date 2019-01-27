extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal death
signal level_complete

const ping_velocity = 1000
const jump_velocity = 400
const max_vel = 400
const max_y_vel = 800
const acceleration = 35
const friction = 20
const gravity = 20
const indicator_size = 1
const indicator_size_decay = 0.98
const max_attachment_length = 500
const angular_acceleration = 80

export (Color) var rope_color

var velocity
var movement_mode
var is_still_jumping

func reset(spawn_pos):
	position = spawn_pos
	velocity = Vector2()
	movement_mode = 'normal'
	is_still_jumping = false
	$indicator.reset()

func _ready():
	reset(position)

func _process(delta):
	if position.y > 350:
		emit_signal('death')

func _physics_process(delta):
	
	if Input.is_action_just_released('jump'):
		is_still_jumping = false
	
	match movement_mode:
		'normal':
			normal_movement()
		'grabbed':
			grabbed_movement()
		'attached':
			attached_movement()

func attach():
	var attachment_point = Vector2()

func attached_movement():
	
	var attachment_point = Vector2()
	draw_line(position, attachment_point, rope_color, 5, true)
	var direction_to_attachment = (attachment_point - position).normalized()
	velocity += direction_to_attachment * angular_acceleration
		
func grabbed_movement():
	
	var axis = Vector2(Input.get_joy_axis(0, 0), Input.get_joy_axis(0, 1))
	
	indicator_size *= indicator_size_decay
	
	$indicator/jump_target.position = axis * 75
	
	if Input.is_action_just_released('grab'):
		velocity = axis.normalized() * ping_velocity * $indicator.charge
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
	
	if is_on_floor() and Input.is_action_just_pressed('jump'):
		is_still_jumping = true
		velocity.y -= jump_velocity
	
func handle_collision(collision):
	var other = collision.collider
	
	if Input.is_action_pressed('grab') and is_on_wall():
		$indicator.start_discharge()
		movement_mode = 'grabbed'
	
	if other.name == 'finish':
		emit_signal('level_complete')
	
	if other.is_in_group('enemy'):
		_collide_with_enemy(other)


func _collide_with_enemy(enemy):
	emit_signal('death')


func sm_discharge():
	while true:
		yield($indicator, "empty")
		movement_mode = 'normal'
		$indicator.start_charge()
	
	
	
	
	