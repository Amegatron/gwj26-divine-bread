extends ProduceUnitCapability

class_name ProduceStoneMasterCapability

func _init():
	targetUnit = "StoneMaster"
	capabilityName = "ProduceStoneMaster"
	icon = IconResources.ICON_STONE_MASTER
	hotkey = KEY_S
	description = "Make Stone Master"
	
	var req = ResourceRequirement.new()
	req.type = TeamResources.TYPE_BREADFORCE
	req.amount = 12
	requirements.append(req)
	
	req = ResourceRequirement.new()
	req.type = TeamResources.TYPE_HOUSE_CAPACITY
	req.amount = UnitHouseCapacities.HOUSE_CAPACITY_STONE_MASTER
	req.isConsumed = false
	requirements.append(req)
