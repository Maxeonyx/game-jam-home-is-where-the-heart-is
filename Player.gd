extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal death
signal level_complete

const jump_velocity = 400
const max_vel = 400
const max_y_vel = 800
const acceleration = 35
const friction = 20
const gravity = 20
const indicator_size = 1
const indicator_size_decay = 0.98

var velocity
var grabbed

func reset(spawn_pos):
	position = spawn_pos
	velocity = Vector2()
	grabbed = false

func _ready():
	reset(position)
	
	$AnimationPlayer.play("syn")

func _process(delta):
	if position.y > 1000:
		emit_signal('death')

func _physics_process(delta):
	
	if grabbed:
		$indicator.scale = Vector2(indicator_size, indicator_size)
		$indicator.show()
		grabbed_movement()
	else:
		indicator_size = 1
		$indicator.hide()
		normal_movement()
		
func grabbed_movement():
	
	var axis = Vector2(Input.get_joy_axis(0, 0), Input.get_joy_axis(0, 1))
	
	indicator_size *= indicator_size_decay
	
	print($indicator.scale)
	
	$indicator/jump_target.position = axis * 75
	
	if Input.is_action_just_released('grab'):
		velocity = axis.normalized() * 400
		grabbed = false
	
	if $indicator.scale.x < 0.2:
		grabbed = false
		
func normal_movement():
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if get_slide_count() > 0:
		for i in range(get_slide_count()):
			handle_collision(get_slide_collision(i))

	if velocity.y < 0 and Input.is_action_pressed('jump'):
		velocity.y += gravity / 2
	else:
		velocity.y += gravity
	
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
		velocity.y -= jump_velocity
	
	if Input.is_action_pressed('grab') and is_on_wall():
		grabbed = true
	
func handle_collision(collision):
	var other = collision.collider
	
	print(other.name)
	
	if other.name == 'finish':
		emit_signal('level_complete')
	
	if other.is_in_group('enemy'):
		_collide_with_enemy(other)

func _collide_with_enemy(enemy):
	emit_signal('death')
	
	
	
	
	
	
	