# NOT USED YEAT
extends ReactOnAttackCapability

class_name MonumentReactOnAttackCapability

func _reaction(target):
	ownerEntity.emit_capability_signal("attacked", {"from": target})
