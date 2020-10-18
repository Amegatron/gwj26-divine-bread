extends Capability

class_name PeriodicBaseCapability

var period = 10 setget , _get_period
var periodCounter = 0.0

var affectedByBonuses = []

func process(delta):
	var actualIncrement = delta
			
	actualIncrement *= get_total_bonus()
	
	periodCounter += actualIncrement
	if periodCounter >= self.period:
		periodCounter -= self.period
		_perform_periodic_capability()

func _perform_periodic_capability():
	pass

func _get_period():
	return period

func get_total_bonus():
	var bonus = 1
	for bonusName in affectedByBonuses:
		if ownerEntity.has_capability(bonusName):
			var cap = ownerEntity.get_capability(bonusName)
			if cap is BonusCapability:
				bonus += cap.get_bonus() - 1
				
	return bonus
