extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const speed = 200

var path

func is_enemy():
	return true

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$AnimationPlayer.play('tendrils')

func _set_path(_path):
	path = _path
	

func _process(delta):
	if path and path.size():
		
		var velocity = (path[1] - position).normalized() * speed
		
		move_and_slide(velocity)
		
	if get_slide_count() > 0:
		for i in range(get_slide_count()):
			handle_collision(get_slide_collision(i))

func handle_collision(collision):
	var other = collision.collider
	if other.name == 'Player':
		 other._collide_with_enemy(self)
	
