extends AttackCapability

class_name RangedAttackCapability

var projectileScene = "res://scenes/RockProjectile.tscn"

func _init():
	strength = 12

func perform_actual_attack(target):
	var projectile = load(projectileScene).instance()
	projectile.initiator = ownerEntity
	
	var startingPos = ownerEntity.position
	if ownerEntity.has_node("ProjectileStartingPosition"):
		startingPos = ownerEntity.get_node("ProjectileStartingPosition").global_position
		
	projectile.position = startingPos
	projectile.z_index = 1000
	
	var cap = ProjectileCapability.new()
	cap.strength = strength
	cap.speed = 500
	cap.target = target
	
	projectile.add_capability(cap)
	
	ownerEntity.level.add_entity(projectile)
