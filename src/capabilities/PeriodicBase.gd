extends Capability

class_name PeriodicBaseCapability

var period = 10 setget , _get_period
var periodCounter = 0.0

func process(delta):
	periodCounter += delta
	if periodCounter >= self.period:
		periodCounter -= self.period
		_perform_periodic_capability()

func _perform_periodic_capability():
	pass

func _get_period():
	return period
