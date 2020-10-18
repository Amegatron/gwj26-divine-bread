extends BonusCapability

class_name PrayableBonusCapability

var factor = 0.4

func _init():
	capabilityName = "PrayableBonus"

func get_bonus():
	var bonus = 1
	if ownerEntity.has_capability("Prayable"):
		var cap = ownerEntity.get_capability("Prayable")
		bonus += min(cap.maxPrayers, cap.currentPrayers) * factor
	
	return bonus
