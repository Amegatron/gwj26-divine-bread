extends Entity

class_name Clubman

onready var animationPlayer = $AnimationPlayer
onready var attackArea = $AttackArea
onready var sightArea = $SightArea
onready var flockArea = $FlockArea setget , _get_flock_area
onready var selectionCircle = $SelectionCircle
onready var collisionShape = $CollisionShape2D

func _init():
	type = Entity.TYPE_UNIT
	maxHealth = 100
	health	 = maxHealth
	houseCapacityCost = UnitHouseCapacities.HOUSE_CAPACITY_CLUBMAN
	
func _ready():
	connect("died", self, "_on_died")

func _set_is_selected(value):
	._set_is_selected(value)
	selectionCircle.visible = value

func _get_flock_area():
	if !flockArea:
		flockArea = get_node("FlockArea")
		
	return flockArea

func _set_team(value):
	._set_team(value)
	if value == Entity.TEAM_ENEMY:
		set_collision_layer_bit(15, false)
		set_collision_layer_bit(16, true)
		
		$AttackArea.set_collision_mask_bit(15, true)
		$AttackArea.set_collision_mask_bit(16, false)
		
		$SightArea.set_collision_mask_bit(15, true)
		$SightArea.set_collision_mask_bit(16, false)
		
		$FlockArea.set_collision_mask_bit(15, false)
		$FlockArea.set_collision_mask_bit(16, true)
		
func _on_died():
	$CollisionShape2D.disabled = true
