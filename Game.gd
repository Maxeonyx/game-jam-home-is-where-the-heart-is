extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var current_level
onready var player = $Player

func _ready():
	sm_levels()
	sm_death_screen()
	
func _process(delta):
	#if current_level:
	#	print('loc', current_level.get_node('camera_location').global_transform.origin)
	#print('cam', $camera.position)
	pass

func sm_death_screen():
	while true:
		yield(player, 'death')
		$camera/death.show()
		remove_child(player)
		$death_cooldown.start()
		yield($death_cooldown, 'timeout')
		$camera/death.hide()
		add_child(player)
		player.reset(current_level.get_node('spawn').global_transform.origin)
		
func sm_levels():
	while true:
		for level in $Levels.get_children():
			current_level = level
			var spawn = current_level.get_node('spawn')
			var camera_location = current_level.get_node('camera_location')
			#spawn.hide()
			#camera_location.hide()
			player.reset(spawn.global_transform.origin)
			$camera.position = camera_location.global_transform.origin
			yield(player, 'level_complete')
		


