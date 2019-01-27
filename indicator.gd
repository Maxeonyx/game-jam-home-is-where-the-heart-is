extends Line2D

signal empty

const maximum_charge = 1
const minimum_charge = 0
const recharge_rate = 0.1
const discharge_rate = 0.2
const jump_cost = 0.25

export (Color) var full_charge_color
export (Color) var charge_color
export (Color) var discharge_color

var charging
var charge

func reset():
	start_charge()
	charge = maximum_charge

func _ready():
	reset()

func start_charge():
	charging = true
	$jump_target.hide()
	modulate = charge_color
	
func start_discharge():
	charging = false
	$jump_target.show()
	modulate = discharge_color
	
func jump():
	if charge >= jump_cost:
		charge -= jump_cost
		return 1
	else:
		charge = 0
		return charge/jump_cost

func _process(delta):
	if charging:
		charge += recharge_rate * delta
	else:
		charge -= discharge_rate * delta
	
	if charge > maximum_charge:
		charge = maximum_charge
		modulate = full_charge_color
	
	if charge < minimum_charge:
		charge = minimum_charge
		emit_signal('empty', charge)
	
	scale = Vector2(charge * 0.8 + 0.2, charge * 0.8 + 0.2)
