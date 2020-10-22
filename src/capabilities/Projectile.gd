extends Capability

class_name ProjectileCapability

var strength = 1
var target setget _set_target
var targetPos
var speed = 200

func _init():
	capabilityName = "Projectile"
	
func process(delta):
	if target:
		targetPos = target.position
				
	if targetPos:
		var dir = targetPos - ownerEntity.position
		if dir.length() > speed * delta:
			ownerEntity.position = ownerEntity.position + dir.normalized() * speed * delta
			if ownerEntity.position.distance_to(targetPos) <= 5:
				hit()
		else:
			ownerEntity.position = ownerEntity.position + dir
			hit()

func hit():
	if target:
		if !target.isDead && target.has_capability("TakeDamage"):
			target.perform_action("TakeDamage", {"strength": strength, "from": ownerEntity.initiator}, true)
	
	targetPos = null
	ownerEntity.queue_death()
	
func _set_target(value):
	target = value
	targetPos = value.position
