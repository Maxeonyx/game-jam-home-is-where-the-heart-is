extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var level_original_state = []
var current_level_i
var current_level
onready var player = $Player

func _ready():
	sm_levels()
	sm_death_screen()
	sm_music()
	sm_game_complete()

func sm_death_screen():
	while true:
		yield(player, 'death')
		$camera/death.show()
		remove_child(player)
		$death_cooldown.start()
		yield($death_cooldown, 'timeout')
		$camera/death.hide()
		add_child(player)
		reset_level()
		
func reset_level():
	current_level.free()
	current_level = level_original_state[current_level_i].instance()
	$Levels.add_child(current_level)
	$Levels.move_child(current_level, current_level_i)
	player.reset(current_level.get_node('spawn').global_transform.origin)
	$camera.position = current_level.get_node('camera_location').global_transform.origin
	

func sm_levels():
	
	for level in $Levels.get_children():
		level.get_node('spawn').hide()
		level.get_node('camera_location').hide()
		
		var ps = PackedScene.new()
		ps.pack(level)
		level_original_state.append(ps)
	
	while true:
		var levels = $Levels.get_children()
		for i in range(len(levels)):
			current_level = levels[i]
			current_level_i = i
			reset_level()
			yield(player, 'level_complete')
			
func sm_music():
	while true:
		for audio in $music.get_children():
			audio.play()
			yield(audio, 'finished')

func sm_game_complete():
	yield(player, 'game_complete')
	get_tree().change_scene('res://HomeScreen.tscn')



