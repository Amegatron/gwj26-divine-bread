extends Capability

class_name AttackCapability

var strength = 10

var currentTarget
var targetPosition
var wanderingTargetedAttack = false
var actualTarget
var stuckAccumulator = 0.0
var stuckTimeout = 1

var attackSound
var confirmSound
var moveCap

var closestEnemy
var closestEnemyRecalcTimeout = 0.2
var closestEnemyRecalcTime = 0.0
var temporaryTarget

var proximity = 5

var movingToTarget = false


func _init():
	capabilityName = "Attack"
	hotkey = KEY_A
	isInHotBar = true
	isTargeted = true

func _set_owner(value):
	._set_owner(value)
	ownerEntity.connect("animation_signal", self, "_on_owner_animation_signal")
	if ownerEntity.has_node("AttackSound"):
		attackSound = ownerEntity.get_node("AttackSound")
	if ownerEntity.has_node("ConfirmSound"):
		confirmSound = ownerEntity.get_node("ConfirmSound")
	
func perform(args, internal = false):
	currentTarget = args["target"]
	
	if args.has("wandering"):
		wanderingTargetedAttack = args["wandering"]
	else:
		wanderingTargetedAttack = false
			
	if !internal:
		if ownerEntity.currentAction && ownerEntity.currentAction != self:
			ownerEntity.currentAction.cancel()
			
		ownerEntity.currentAction = self
	
#	if !internal && confirmSound && ownerEntity.team == Entity.TEAM_PLAYER:
#		if !confirmSound.playing:
#			confirmSound.play()
			
	return true

func process(delta):
	if currentTarget is Entity && currentTarget.isDead:
		cancel()
		return
			
	if temporaryTarget is Entity && temporaryTarget.isDead:
		temporaryTarget = null
		closestEnemyRecalcTime = 0.0
	
	closestEnemy = null
	closestEnemyRecalcTime += delta
	if closestEnemyRecalcTime >= closestEnemyRecalcTimeout:
		closestEnemyRecalcTime = 0.0 # or -closestEnemyRecalcTimeout
		var minDistance = 100000000
		var bodies = ownerEntity.sightArea.get_overlapping_bodies()
		for entity in bodies:
			if entity != ownerEntity && entity is Entity && entity.team != ownerEntity.team && !entity.isDead && entity.has_capability("TakeDamage"):
				var dist = ownerEntity.position.distance_to(entity.position)
				if dist < minDistance:
					minDistance = dist
					closestEnemy = entity
		
		if ownerEntity.isSelected:
			pass
			
		if closestEnemy && (!currentTarget || currentTarget is Vector2 || currentTarget is Entity && wanderingTargetedAttack):
			temporaryTarget = closestEnemy
		elif !closestEnemy:
			temporaryTarget = null
	
func process_physics(delta):
	if ownerEntity.currentAction && ownerEntity.currentAction != self: # && ownerEntity.currentAction.capabilityName != "Pray"):
		return
			
#	stuckAccumulator -= delta
#	if stuckAccumulator > 0:
#		return
			
	if !moveCap:
		moveCap = ownerEntity.get_capability("Move")
		moveCap.connect("finished", self, "_on_move_finished")
		
	if ownerEntity.isSelected:
		pass
		
	var finalTarget = temporaryTarget if temporaryTarget else currentTarget
	
#	if moveCap.stuckAccumulator >= 1:
##		moveCap.stuckAccumulator = 0.0
#		moveCap.cancel()
#		if currentTarget is Vector2 && ownerEntity.position.distance_to(currentTarget) > proximity:
#			stuckAccumulator = stuckTimeout
#			return
#		else:
#			cancel()
#		return
		
	actualTarget = null
	if finalTarget:
		if finalTarget is Entity && !finalTarget.isDead:
			if ownerEntity.attackArea.overlaps_body(finalTarget):
				actualTarget = finalTarget
				movingToTarget = false
				if moveCap:
					# moveCap.disconnect("finished", self, "_on_move_finished")
					moveCap.cancel()
					
#				if ownerEntity.currentAction && ownerEntity.currentAction.capabilityName == "Pray":
#					ownerEntity.currentAction.cancel()
					
				if !ownerEntity.currentAction:
					ownerEntity.currentAction = self
					
				if ownerEntity.animationPlayer.current_animation != "Attack":
					if (ownerEntity.position.x > finalTarget.position.x):
						ownerEntity.set_look_direction(Entity.LOOK_LEFT)
					else:
						ownerEntity.set_look_direction(Entity.LOOK_RIGHT)
					
					ownerEntity.animationPlayer.stop(true)
					ownerEntity.animationPlayer.play("Attack")
				
				return

		if ownerEntity.animationPlayer.current_animation != "Attack":
#			if currentTarget is Vector2 && ownerEntity.position.distance_to(currentTarget) <= proximity:
#				cancel()
#				return
			movingToTarget = true
			if moveCap && (typeof(moveCap.currentTarget) != typeof(finalTarget) || moveCap.currentTarget != finalTarget):
				moveCap.perform({"target": finalTarget}, true)

	elif ownerEntity.currentAction == self:
		ownerEntity.currentAction = null

func _on_move_finished():
	if movingToTarget:
		print ("Attack: move finished")
		cancel()

func _on_owner_animation_signal(signalName):
	if signalName == "Attack" && actualTarget && !actualTarget.isDead:
		if attackSound && !attackSound.playing:
			attackSound.play()
		perform_actual_attack(actualTarget)

func perform_actual_attack(target):
	target.perform_action("TakeDamage", {"strength": strength}, true)

func cancel():
	currentTarget = null
	temporaryTarget = null
	if moveCap:
		moveCap.stuckAccumulator = 0.0
		moveCap.cancel()
		
	if ownerEntity.currentAction == self:
		ownerEntity.currentAction = null
		
	if ownerEntity.animationPlayer.current_animation == "Attack":
		ownerEntity.animationPlayer.seek(0, true)
		ownerEntity.animationPlayer.stop()
