extends ProgressBaseCapability

class_name ResearchStoneMasterCapability

func _init():
	icon = IconResources.ICON_RESEARCH_STONE_MASTER
	timeNeeded = 60
	hotkey = KEY_S
	description = "Research ranged unit: Stone Master"
	
	var req = ResourceRequirement.new()
	req.type = TeamResources.TYPE_BREADFORCE
	req.amount = 30
	
	requirements.append(req)

func progress_finished():
	var sound = OneTimeSound.new()
	sound.play(SoundResources.SOUND_EVENT, ownerEntity)

	var entities = ownerEntity.level.entities.get_children()
	for ent in entities:
		if ent is Cave && ent.team == ownerEntity.team:
			var cap = ProduceStoneMasterCapability.new()
			ent.add_capability(cap)
			break
			
	ownerEntity.remove_capability(capabilityName)
