extends ProgressBaseCapability

class_name UpgradeHouseCapability

var upgradeAmount = 5

func _init():
	capabilityName = "UpgradeHouse"
	hotkey = KEY_U
	icon = IconResources.ICON_UPGRADE_HOUSE
	timeNeeded = 30
	description = "Upgrade the cave (more capacity, faster production)"
	
	var req = ResourceRequirement.new()
	req.type = TeamResources.TYPE_BREADFORCE
	req.amount = 20
	
	requirements.append(req)

func progress_finished():
	var sound = OneTimeSound.new()
	sound.play(SoundResources.SOUND_EVENT, ownerEntity)
	var manager = ownerEntity.level.gameManager
	var res = manager.get_team_resource(ownerEntity.team)
	res.increment_resource_by_type(TeamResources.TYPE_HOUSE_CAPACITY_MAX, upgradeAmount)
	res.increment_resource_by_type(TeamResources.TYPE_HOUSE_UPGRADES)
