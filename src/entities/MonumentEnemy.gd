extends Entity

class_name MonumentEntity

func _init():
	type = Entity.TYPE_BUILDING
	defaultTargetAction = "Attack" # Pray
	team = Entity.TEAM_ENEMY
	maxHealth = 5000
	health = maxHealth

# Called when the node enters the scene tree for the first time.
func _ready():
	#$Sprite.material = $Sprite.material.duplicate(true)
	pass

func _set_is_selected(value):
	pass

func _on_capability_added(capability):
	._on_capability_added(capability)
#	if capability is PrayableCapability:
#		$PrayersInfo.prayableCapability = capability
#	elif capability is PrayableBonusCapability:
#		$PrayersInfo.prayableBonusCapability = capability
