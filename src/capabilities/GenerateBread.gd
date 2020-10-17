extends PeriodicBaseCapability

class_name GenerateBreadCapability

func _init():
	capabilityName = "GenerateBread"
	hotkey = null
	period = 5

func _perform_periodic_capability():
	var res = ownerEntity.level.gameManager.get_team_resource(ownerEntity.team)
	var monumentLevel = res.get_resource_by_type(TeamResources.TYPE_MONUMENT_LEVEL)
	var amount = _get_amount_for_level(monumentLevel)
	res.set_resource_by_type(TeamResources.TYPE_BREADFORCE, res.get_resource_by_type(TeamResources.TYPE_BREADFORCE) + amount)

func _get_amount_for_level(level):
	return level
	
func _get_period():
	return period
