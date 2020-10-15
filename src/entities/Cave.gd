extends Entity

class_name Cave

func _init():
	type = Entity.TYPE_BUILDING
	team = Entity.TEAM_PLAYER

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.material = $Sprite.material.duplicate(true)
	
	var cap = ProduceUnitCapability.new()
	cap.capabilityName = "ProduceClubman"
	cap.hotkey = KEY_A
	cap.targetUnit = "Clubman"
	add_capability(cap)

func _set_is_selected(value):
	._set_is_selected(value)
	if value:
		$Sprite.material.set_shader_param("aura_color", Color("99812c"))
	else:
		$Sprite.material.set_shader_param("aura_color", Color(0))
