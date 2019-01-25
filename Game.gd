extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	sm_death_screen()

func sm_death_screen():
	yield($Player, 'death')
	$Control.show()
