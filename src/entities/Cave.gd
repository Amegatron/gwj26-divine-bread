extends Entity

class_name Cave

func _init():
	type = Entity.TYPE_BUILDING
	# team = Entity.TEAM_PLAYER

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
