extends ProduceUnitCapability

class_name ProduceClubmanCabability

func _init():
	targetUnit = "Clubman"
	capabilityName = "ProduceClubman"
	icon = IconResources.ICON_CLUBMAN
	description = "Make Clubman"
	
	var req = ResourceRequirement.new()
	req.type = TeamResources.TYPE_BREADFORCE
	req.amount = 10
	req.isConsumed = true
	requirements.append(req)
	
	req = ResourceRequirement.new()
	req.type = TeamResources.TYPE_HOUSE_CAPACITY
	req.amount = UnitHouseCapacities.HOUSE_CAPACITY_CLUBMAN
	req.isConsumed = false
	requirements.append(req)
