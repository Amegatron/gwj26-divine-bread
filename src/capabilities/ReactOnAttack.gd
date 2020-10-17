extends Capability

class_name ReactOnAttackCapability

func _init():
	capabilityName = "ReactOnAttack"
	
func _set_owner(value):
	._set_owner(value)
	ownerEntity.connect("action_performed", self, "_on_owner_action_performed")
	
func _on_owner_action_performed(cap, args, result):
	if cap.capabilityName == "TakeDamage" && args.has("from"):
		var bodies = (ownerEntity.sightArea as Area2D).get_overlapping_bodies()
		for body in bodies:
			if body is Entity && body.team == ownerEntity.team && body.has_capability("ReactOnAttack") && body.has_capability("Attack") && !body.currentAction:
				var target = args["from"]
				body.perform_action("Attack", {"target": target, "wandering": true}, true)
		
			
