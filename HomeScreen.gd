extends Node

signal start_game

export (Color) var start_modulate
export (Color) var end_modulate

func _ready():
	$twee.interpolate_property($TitleScreen, 'modulate', start_modulate, end_modulate, 4, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$twee.start()
	tween_proxy()
	yield(self, 'start_game')
	get_tree().change_scene('res://Game.tscn')
	
func _process(delta):
	if Input.is_action_pressed('start_game'):
		emit_signal('start_game')

func tween_proxy():
	yield($twee, "tween_completed")
	$ColorRect.show()