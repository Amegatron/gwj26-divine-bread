extends PeriodicBaseCapability

class_name GenerateBreadCapability

var amount = 1

func _init():
	capabilityName = "GenerateBread"
	hotkey = null
	period = 1

func _perform_periodic_capability():
	ownerEntity.level.gameManager.get_team_resource(ownerEntity.team).breadForce += amount
	print("+1 bread for team ", ownerEntity.team)

func _get_period():
	# TODO: paraying boosts speed
	return period
