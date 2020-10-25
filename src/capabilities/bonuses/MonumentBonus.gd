extends BonusCapability

class_name MonumentBonusCapability

var factor = 0.2

func _init():
	capabilityName = "MonumentBonus"
	
func get_bonus():
	var manager = ownerEntity.level.gameManager
	var res = manager.get_team_resource(ownerEntity.team)
	var upgrades = res.get_resource_by_type(TeamResources.TYPE_MONUMENT_LEVEL) - 1
	return 1 + upgrades * factor
