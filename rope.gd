extends Line2D

var endpoint

func _ready():
	reset()

func reset():
	endpoint = position

func _process(delta):
	points[0] = position
	points[1] = endpoint
