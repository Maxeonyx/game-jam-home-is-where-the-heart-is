extends Navigation2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func get_player():
	if get_parent():
		return get_parent().get_node('Player')

func sm_calculate_enemy_paths():
	while true:
		$recalculate_timer.start()
		yield($recalculate_timer, 'timeout')
		
		var player = get_player()
		if not player:
			continue
		
		var underlings = []
		for child in get_children():
			if child.is_in_group('enemy'):
				underlings.append(child)
		
		for minion in underlings:
			if minion.has_method('_set_path'):
				var path = get_simple_path(minion.position, player.position)
				minion._set_path(path)