extends Entity

class_name Clubman

onready var animationPlayer = $AnimationPlayer
onready var attackArea = $AttackArea
onready var sightArea = $SightArea
onready var selectionCircle = $SelectionCircle

func _init():
	type = Entity.TYPE_UNIT
	health = 10
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _set_is_selected(value):
	._set_is_selected(value)
	selectionCircle.visible = value
