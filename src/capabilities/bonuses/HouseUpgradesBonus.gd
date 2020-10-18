extends BonusCapability

class_name HouseUpgradesBonusCapability

var factor = 0.2

func _init():
	capabilityName = "HouseUpgradesBonus"

func get_bonus():
	var manager = ownerEntity.level.gameManager
	var res = manager.get_team_resource(ownerEntity.team)
	var upgrades = res.get_resource_by_type(TeamResources.TYPE_HOUSE_UPGRADES)
	return 1 + upgrades * factor
