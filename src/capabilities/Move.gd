extends Capability

class_name MoveCapability

var speed = 100

var currentTarget

var stuckAccumulator = 0.0
var stuckWait = 0.0
var stuckTimeout = 1
var noPushCounter = 0
var pushGroup
var dir
var dirNormalized

const CAPABILITY_NAME = "Move"
const NO_PUSH_FRAMES_LIMIT = 10

var lastMoveCollided = false
var lastVelocity

# flocking weights
var alignmentWeight = 1
var separationWeight = 1
var cohesionWeight = 0.5

const FLOCK_FRAMES = 4
var flockFrame = randi() % FLOCK_FRAMES

var alignmentVector = Vector2(0, 0)
var cohesionVector = Vector2(0, 0)

var neighborUnits = []

var pushableCap

func _set_owner(value):
	._set_owner(value)
	ownerEntity.flockArea.connect("body_entered", self, "_on_flock_area_body_entered")
	ownerEntity.flockArea.connect("body_exited", self, "_on_flock_area_body_exited")
	
func _on_flock_area_body_entered(body):
	if body is Entity && body.team == ownerEntity.team && body != ownerEntity:
		neighborUnits.append(body)
		
func _on_flock_area_body_exited(body):
	if body is Entity && body.team == ownerEntity.team:
		var pos = neighborUnits.find(body)
		if pos >= 0:
			neighborUnits.remove(pos)
	
func _init():
	capabilityName = CAPABILITY_NAME
	hotkey = KEY_M
	isInHotBar = true
	isTargeted = true

func perform(args, internal = false):	
	stuckAccumulator = 0.0
	stuckWait = 0.0
	noPushCounter = 0
	flockFrame = randi() % FLOCK_FRAMES
	
	if pushGroup:
		pushGroup.continuePushing = false
		pushGroup = null
	
#	if !internal && ownerEntity.has_node("ConfirmSound") && ownerEntity.team == Entity.TEAM_PLAYER:
#		if !ownerEntity.get_node("ConfirmSound").playing:
#			ownerEntity.get_node("ConfirmSound").play()

	if !internal:
		if ownerEntity.currentAction && ownerEntity.currentAction != self:
			ownerEntity.currentAction.cancel()
		ownerEntity.currentAction = self
		
	currentTarget = args["target"]
	
func _get_cohesion_vector():
	var vel = Vector2(0, 0)
	var counter = 0
	for ent in neighborUnits:
		if ent.lastVelocity.length() > 1 && ent.position.distance_to(ownerEntity.position) <= 50:
			counter += 1
			vel += ent.position
		
	if counter > 0:
		vel /= counter
		vel -= ownerEntity.position
#		if vel.length() < 50:
#			return -vel.normalized()
#		else:
#			return Vector2(0, 0)
		return -vel.normalized()
	else:
		return vel

func _get_alignment_vector():
	var vel = Vector2(0, 0)
	var counter = 0
	for ent in neighborUnits:
		if ent.lastVelocity.length() > 0 && dirNormalized.length() > 0:
			if ent.lastVelocity.normalized().dot(dirNormalized) > 0:
				counter += 1
				vel += ent.lastVelocity
			
	if counter > 0:
		vel /= counter
		vel = vel.normalized()
		
	return vel
	
func _get_separation_vector():
	var vel = Vector2(0, 0)
	var counter = 0
	for ent in neighborUnits:
		counter += 1
		vel += ent.position - ownerEntity.position
	
	if counter > 0:
		vel = vel.normalized() * -1 / counter
		return vel
	else:
		return Vector2(0, 0)
		
func _get_neighbor_teammates():
	var neighbors = []
	for ent in ownerEntity.level.entities.get_children():
		if ent is Entity && ent.team == ownerEntity.team && ownerEntity.position.distance_to(ent.position) <= 300:
			neighbors.append(ent)
			
	return neighbors
			
func process(delta):
	if currentTarget:
		flockFrame += 1
		if flockFrame >= FLOCK_FRAMES:
			alignmentVector = _get_alignment_vector()
			cohesionVector = _get_cohesion_vector()
			flockFrame = 0
		
	if pushGroup:
		pushGroup.process(delta)

# TODO: add simple avoidance behaviour: is entity is stuck moving, try to move
# to a random close position, and the continue main move
func process_physics(delta):
#	neighborUnits = _get_neighbor_teammates()
	if !pushableCap:
		pushableCap = ownerEntity.get_capability("Pushable")
		
	var targetPosition = Vector2(0, 0)
	
	dir = Vector2(0, 0)
	var dirLen = 0
	dirNormalized = Vector2(0, 0)
	var oldPos = ownerEntity.position
	var finalDir = Vector2(0, 0)
	
	if currentTarget:						
		if currentTarget is Vector2:
			targetPosition = currentTarget
		elif currentTarget is Entity:
			targetPosition = currentTarget.position
			
		dir = targetPosition - ownerEntity.position
		dirLen = dir.length()
		dirNormalized = dir.normalized()
				
		finalDir = dir.normalized() + alignmentVector * alignmentWeight
		finalDir += cohesionVector * cohesionWeight
		
	if ownerEntity.isSelected:
		pass
		
	finalDir += pushableCap.finalPush.normalized() * 1.5
			
	finalDir = finalDir.normalized()
	var velocity = ownerEntity.move_and_slide(finalDir * speed, Vector2(0, 0), false, 2)
	if dirLen > 2:
		ownerEntity.lastVelocity = velocity
	else:
		ownerEntity.lastVelocity = Vector2(0, 0)
		
	if ownerEntity.get_slide_count() == 0:
		if pushGroup:
			noPushCounter += 1
			if noPushCounter >= NO_PUSH_FRAMES_LIMIT:
				pushGroup.continuePushing = false
				pushGroup = null
				noPushCounter = 0
	elif !pushGroup && currentTarget:
		pushGroup = PushGroup.new()
		pushGroup.connect("entity_added", self, "_on_entity_added_to_push_group", [pushGroup])
		if !pushGroup.add_entity(ownerEntity):
			return
	
	var allPushGroups = []
	if pushGroup && pushGroup.continuePushing:
		allPushGroups.append(pushGroup)
		
	for grp in pushableCap.currentGroups:
		if grp && grp.continuePushing:
			allPushGroups.append(grp)

	if allPushGroups.size() > 0:
		for i in range(ownerEntity.get_slide_count()):
			var coll = ownerEntity.get_slide_collision(i)
			var target = coll.collider
			if target is Entity:
#					if !pushGroup.add_entity(target):
#						return
				var otherPushableCap = target.get_capability("Pushable")				
				if otherPushableCap:
					var actualAffectedGroups = []
					for grp in allPushGroups:
						if grp.add_entity(target):
							actualAffectedGroups.append(grp)

					if actualAffectedGroups.size() > 0:
						var pushDir
						pushDir = coll.normal * -1
						# pushDir = (pushDir + coll.collider_velocity.normalized())/2
	#							var angle = pushDir.angle_to(dir)
	#							# force some side-movement
	#							if abs(angle) < PI/6:
	#								pushDir = dirNormalized.rotated(PI/6 * -sign(angle))
						otherPushableCap.queue_push(pushDir * speed, actualAffectedGroups, ownerEntity)
			
	if dirLen > 2:
		var diffX = ownerEntity.position.x - oldPos.x
		if diffX > 0.2:
			ownerEntity.set_look_direction(Entity.LOOK_RIGHT)
		elif diffX < -0.2:
			ownerEntity.set_look_direction(Entity.LOOK_LEFT)

		if ownerEntity.animationPlayer.current_animation != "Walk":
			ownerEntity.animationPlayer.stop(true)
			ownerEntity.animationPlayer.play("Walk")
	else:
		if currentTarget:
			finished("position")
		cancel()
		return
		
	# ownerEntity.z_index = ownerEntity.position.y
#	else:
#		finished("close enough")
#		return

func cancel():
	currentTarget = null
	stuckAccumulator = 0.0
	noPushCounter = 0
	ownerEntity.lastVelocity = Vector2(0, 0)
	alignmentVector = Vector2(0, 0)
	cohesionVector = Vector2(0, 0)
	
	if pushGroup:
		pushGroup.continuePushing = false
		pushGroup = null
		
	if ownerEntity.currentAction == self:
		ownerEntity.currentAction = null
		
	if ownerEntity.animationPlayer.current_animation == "Walk":
		ownerEntity.animationPlayer.stop()

func _on_entity_added_to_push_group(entity, grp):
	var reached = false
			
	if entity.isSelected:
		pass
					
	if currentTarget is Entity && entity == currentTarget:
		reached = true
	elif currentTarget is Vector2 && entity is CollisionObject2D:
#		if entity.lastVelocity.length() > 0:
#			return
			
		var testShape = CircleShape2D.new()
		testShape.radius = 3
		var testTransform = Transform2D(0, currentTarget)
		
		# fallback for arbitrary shapes
		var ownerTransform = entity.shape_owner_get_transform(0)
		var finalOwnerTransform = entity.global_transform * ownerTransform
		for i in range(entity.shape_owner_get_shape_count(0)):
			var shape = entity.shape_owner_get_shape(0, i)
			if shape is CircleShape2D:
				if currentTarget.distance_to(finalOwnerTransform.origin) <= shape.radius:
					reached = true
					break
			else:
				# fallback for arbitrary shapes
				# print("WARNING: non circle shape while pushing")
				if shape.collide(finalOwnerTransform, testShape, testTransform):
					reached = true
					break
				
	if reached:
		finished("collision")

func queue_finished():
	pass
	
func finished(reason = "because"):
	cancel()
#	print("Move finished: ", reason)
	emit_signal("finished")
