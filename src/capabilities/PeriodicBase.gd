extends Capability

class_name PeriodicBaseCapability

var period = 10 setget , _get_period
var periodCounter = 0.0

func process(delta):
	var actualIncrement = delta
	
	if ownerEntity.has_capability("Prayable"):
		var cap = ownerEntity.get_capability("Prayable")
		actualIncrement *= cap.get_prayer_bonus()
		
	periodCounter += actualIncrement
	if periodCounter >= self.period:
		periodCounter -= self.period
		_perform_periodic_capability()

func _perform_periodic_capability():
	pass

func _get_period():
	return period
