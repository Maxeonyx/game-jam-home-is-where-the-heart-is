extends Line2D

var endpoint

func _ready():
	reset()

func reset():
	hide()
	endpoint = to_global(position)

func _process(delta):
	points[0] = position
	points[1] = to_local(endpoint)
