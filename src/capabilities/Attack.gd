extends Capability

class_name AttackCapability

var strength = 10

var currentTarget
var targetPosition
var wanderingTargetedAttack = false
var actualTarget
var stuckAccumulator = 0.0
var stuckTimeout = 1

func _init():
	capabilityName = "Attack"
	hotkey = KEY_A
	isInHotBar = true
	isTargeted = true

func _set_owner(value):
	._set_owner(value)
	ownerEntity.connect("animation_signal", self, "_on_owner_animation_signal")
	
func perform(args, internal = false):
	currentTarget = args["target"]
	if args.has("wandering"):
		wanderingTargetedAttack = args["wandering"]
	else:
		wanderingTargetedAttack = false
	
	if !internal:
		ownerEntity.currentAction = self
	
	if !internal && ownerEntity.has_node("ConfirmSound") && ownerEntity.team == Entity.TEAM_PLAYER:
		if !ownerEntity.get_node("ConfirmSound").playing:
			ownerEntity.get_node("ConfirmSound").play()
			
	return true

func process(delta):
	if ownerEntity.currentAction && ownerEntity.currentAction != self:
		return
			
	stuckAccumulator -= delta
	if stuckAccumulator > 0:
		return
		
	if currentTarget is Entity && currentTarget.isDead:
		currentTarget = null
		if ownerEntity.currentAction == self:
			ownerEntity.currentAction = null
			return
		
	var minDistance = 100000000
	var closestEnemy
	var bodies = ownerEntity.sightArea.get_overlapping_bodies()
	for entity in bodies:
		if entity != ownerEntity && entity is Entity && entity.team != ownerEntity.team && !entity.isDead && entity.has_capability("TakeDamage"):
			var dist = ownerEntity.position.distance_to(entity.position)
			if dist < minDistance:
				minDistance = dist
				closestEnemy = entity

	var temporaryTarget = null
	if closestEnemy && (!currentTarget || currentTarget is Vector2 || currentTarget is Entity && wanderingTargetedAttack):
		temporaryTarget = closestEnemy

	var moveCap = ownerEntity.get_capability("Move")
	if moveCap.stuckAccumulator >= 1:
		moveCap.cancel()
		stuckAccumulator = stuckTimeout
		return
	
	var finalTarget = temporaryTarget if temporaryTarget else currentTarget
		
	if ownerEntity.isSelected:
		pass
		
	actualTarget = null
	if finalTarget:
		if finalTarget is Entity && !finalTarget.isDead:
			var attackRangeEntities = ownerEntity.attackArea.get_overlapping_bodies()
			for testAttack in attackRangeEntities:
				if testAttack != ownerEntity:
					if testAttack == finalTarget:
						actualTarget = finalTarget
						if moveCap:
							moveCap.cancel()
							
						ownerEntity.currentAction = self
							
						if ownerEntity.animationPlayer.current_animation != "Attack":
							if (ownerEntity.position.x > testAttack.position.x):
								ownerEntity.set_look_direction(Entity.LOOK_LEFT)
							else:
								ownerEntity.set_look_direction(Entity.LOOK_RIGHT)
								
							ownerEntity.animationPlayer.play("Attack")

		if ownerEntity.animationPlayer.current_animation != "Attack":
			if moveCap && (typeof(moveCap.currentTarget) != typeof(finalTarget) || moveCap.currentTarget != finalTarget):
				ownerEntity.perform_action("Move", {"target": finalTarget}, true)
	elif ownerEntity.currentAction == self:
		ownerEntity.currentAction = null

func _on_owner_animation_signal(signalName):
	if signalName == "Attack" && actualTarget && !actualTarget.isDead:
		if ownerEntity.has_node("AttackSound") && !ownerEntity.get_node("AttackSound").playing:
			ownerEntity.get_node("AttackSound").play()
		perform_actual_attack(actualTarget)

func perform_actual_attack(target):
	target.perform_action("TakeDamage", {"strength": strength}, true)

func cancel():
	currentTarget = null
	var moveCap = ownerEntity.get_capability("Move")
	if moveCap:
		moveCap.stuckAccumulator = 0.0
	if ownerEntity.currentAction == self:
		ownerEntity.currentAction = null
		
	if ownerEntity.animationPlayer.current_animation == "Attack":
		ownerEntity.animationPlayer.seek(0, true)
		ownerEntity.animationPlayer.stop()
