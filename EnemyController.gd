extends Navigation2D

func _ready():
	sm_calculate_enemy_paths()

func get_player():
	if get_tree().get_root().get_node('Game').has_node('Player'):
		return get_tree().get_root().get_node('Game').get_node('Player')

func sm_calculate_enemy_paths():
	while true:
		$recalculate_timer.start()
		yield($recalculate_timer, 'timeout')
		
		var player = get_player()
		if not player:
			continue
		
		var underlings = []
		for child in get_children():
			if child.has_method('is_enemy') and child.is_enemy():
				underlings.append(child)
		
		for minion in underlings:
			if minion.has_method('_set_path'):
				var path = get_simple_path(minion.position, player.position)
				minion._set_path(path)
