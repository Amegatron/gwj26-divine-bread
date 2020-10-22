extends AttackCapability

class_name RangedAttackCapability

var projectileScene = "res://scenes/RockProjectile.tscn"

var startingPos

func _init():
	strength = 12
	
func _set_owner(value):
	._set_owner(value)
	startingPos = ownerEntity.position
	if ownerEntity.has_node("ProjectileStartingPosition"):
		startingPos = ownerEntity.get_node("ProjectileStartingPosition")


func perform_actual_attack(target):
	var projectile = load(projectileScene).instance()
	projectile.initiator = ownerEntity
			
	projectile.position = startingPos.global_position
	projectile.z_index = 1000
	
	var cap = ProjectileCapability.new()
	cap.strength = strength
	cap.speed = 400
	cap.target = target
	
	projectile.add_capability(cap)
	
	ownerEntity.level.add_entity(projectile)
