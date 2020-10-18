extends Entity

class_name Monument

func _init():
	type = Entity.TYPE_BUILDING
	maxHealth = 5000
	health = maxHealth

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.material = $Sprite.material.duplicate(true)

func _set_is_selected(value):
	._set_is_selected(value)
	if value:
		$Sprite.material.set_shader_param("aura_color", _get_selection_color())
	else:
		$Sprite.material.set_shader_param("aura_color", Color(0))
		
func _get_selection_color():
	match team:
		TEAM_PLAYER:
			return Color("99812c")
		TEAM_ENEMY:
			return Color(1, 0, 0)

func _on_capability_added(capability):
	._on_capability_added(capability)
	if capability is PrayableCapability:
		$PrayersInfo.prayableCapability = capability
	elif capability is PrayableBonusCapability:
		$PrayersInfo.prayableBonusCapability = capability
