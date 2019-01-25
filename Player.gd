extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal death

const jump_velocity = 400
const max_vel = 400
const max_y_vel = 800

var acceleration = 35
var friction = 20
var velocity = Vector2()
var gravity = 20

var grabbed = false

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	sm_lifecycle()
	
	$AnimationPlayer.play("syn")

func sm_lifecycle():
	yield(self, 'death')
	print('i died')
	

func _process(delta):
	if position.y > 1000:
		emit_signal('death')

func _physics_process(delta):
	
	if grabbed:
		grabbed_movement()
	else:
		normal_movement()
		
func grabbed_movement():
	
	var axis = Vector2(Input.get_joy_axis(0, 0), Input.get_joy_axis(0, 1))
	
	$indicator/jump_target.position = axis * 75
	
	if Input.is_action_just_released('grab'):
		velocity = axis.normalized() * 400
		grabbed = false
		$indicator.hide()
		
func normal_movement():
	
	velocity = move_and_slide(velocity, Vector2(0, -1))

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
		$indicator.show()
	
	
	
	
	
	
	
	