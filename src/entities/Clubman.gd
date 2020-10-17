extends Entity

class_name Clubman

onready var animationPlayer = $AnimationPlayer
onready var attackArea = $AttackArea
onready var sightArea = $SightArea
onready var selectionCircle = $SelectionCircle

func _init():
	type = Entity.TYPE_UNIT
	maxHealth = 100
	health = maxHealth
	houseCapacityCost = UnitHouseCapacities.HOUSE_CAPACITY_CLUBMAN
	
func _set_is_selected(value):
	._set_is_selected(value)
	selectionCircle.visible = value
