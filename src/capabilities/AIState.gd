extends Capability

class_name AIStateCapability

const STATE_NEWCOMER = 1
const STATE_PRAYER = 2
const STATE_DEFENDER = 3
const STATE_ATTACKER = 4

var state = STATE_NEWCOMER

func _init():
	capabilityName = "AIState"
	
func process(delta):
	pass
