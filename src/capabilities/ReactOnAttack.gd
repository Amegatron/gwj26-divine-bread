extends Capability

class_name ReactOnAttackCapability

func _init():
	capabilityName = "ReactOnAttack"
	
func _set_owner(value):
	._set_owner(value)
	ownerEntity.connect("action_performed", self, "_on_owner_action_performed")
	
func _on_owner_action_performed(cap, args, result):
	if cap.capabilityName == "TakeDamage" && args.has("from"):
		_reaction(args["from"])
		
func _reaction(target):
	_react_with_attack(ownerEntity, target)
	
	var moveCap = ownerEntity.get_capability("Move")		
	if moveCap.neighborUnits && moveCap.neighborUnits.size() > 0:
		for ent in moveCap.neighborUnits:
			_react_with_attack(ent, target)

func _react_with_attack(unit, target):
	if !unit.currentAction || unit.currentAction.capabilityName == "Pray":
		unit.perform_action("Attack", {"target": target, "wandering" : true})
