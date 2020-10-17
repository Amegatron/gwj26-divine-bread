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
		ownerEntity.position = ownerEntity.position + dir.normalized() * speed * delta
		if ownerEntity.position.distance_to(targetPos) <= 5:
			hit()
			return
			
func _set_owner(value):
	._set_owner(value)
	if ownerEntity.collisionArea:
		ownerEntity.collisionArea.connect("body_entered", self, "_on_body_entered")
	
func _on_body_entered(body):
	if body is Entity && body == target:
		hit()
	
func hit():
	if target && target.has_capability("TakeDamage"):
		target.perform_action("TakeDamage", {"strength": strength, "from": ownerEntity.initiator}, true)
		
	ownerEntity.queue_death()
	
func _set_target(value):
	target = value
	targetPos = value.position
