extends Capability

class_name TakeDamageCapability

func _init():
	capabilityName = "TakeDamage"
	
func perform(args, internal = false):
	if ownerEntity.health > 0:
		if randf() > 0.1:
			ownerEntity.health -= args["strength"]
			return true
	return false
