extends Entity

class_name Monument

func _init():
	type = Entity.TYPE_BUILDING
	defaultTargetAction = "Move" # Pray
	team = Entity.TEAM_PLAYER
	maxHealth = 5000
	health = maxHealth

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.material = $Sprite.material.duplicate(true)
	var testCap = GenerateBreadCapability.new()
	add_capability(testCap)

func _set_is_selected(value):
	._set_is_selected(value)
	if value:
		$Sprite.material.set_shader_param("aura_color", Color("99812c"))
	else:
		$Sprite.material.set_shader_param("aura_color", Color(0))
