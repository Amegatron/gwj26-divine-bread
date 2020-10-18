extends ProgressBaseCapability

class_name UpgradeMonumentCapability

var manager

func _init():
	capabilityName = "UpgradeMonument"
	hotkey = KEY_U
	icon = IconResources.ICON_UPGRADE_MONUMENT
	description = "Upgrade monument"
	
func _set_owner(value):
	._set_owner(value)
	manager = ownerEntity.level.gameManager
	_update_parameters()
	
func _update_parameters():
	var currentLevel = manager.get_team_resource(ownerEntity.team).get_resource_by_type(TeamResources.TYPE_MONUMENT_LEVEL)
	timeNeeded = _get_time_needed_for_next_level(currentLevel)
	self.requirements = _get_requirements_for_next_level(currentLevel)
	
func _get_time_needed_for_next_level(currentLevel):
	var time = currentLevel * 100 + (currentLevel - 1) * 20
	return time

func _get_requirements_for_next_level(currentLevel):
	var reqs = []
	
	var req = ResourceRequirement.new()
	req.type = TeamResources.TYPE_BREADFORCE
	req.amount = currentLevel * 50 + (currentLevel - 1) * 20
	reqs.append(req)
	
	return reqs

func progress_finished():
	if ownerEntity.team == Entity.TEAM_PLAYER:
		var sound = OneTimeSound.new()
		sound.play(SoundResources.SOUND_EVENT, ownerEntity)
	var res = manager.get_team_resource(ownerEntity.team)
	res.increment_resource_by_type(TeamResources.TYPE_MONUMENT_LEVEL)
	_update_parameters()
