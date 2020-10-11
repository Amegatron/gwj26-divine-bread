extends Entity

class_name Monument

func _init():
	type = Entity.TYPE_BUILDING
	defaultTargetAction = "Move" # Pray
	team = Entity.TEAM_PLAYER

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.material = $Sprite.material.duplicate(true)

func _set_is_selected(value):
	._set_is_selected(value)
	if value:
		$Sprite.material.set_shader_param("aura_color", Color("99812c"))
	else:
		$Sprite.material.set_shader_param("aura_color", Color(0))
