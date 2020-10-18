extends Capability

class_name MoveCapability

var speed = 100

var currentTarget
var distanceApproximation = 5

var stuckAccumulator = 0.0
var stuckWait = 0.0
var stuckTimeout = 1

const CAPABILITY_NAME = "Move"

func _init():
	capabilityName = CAPABILITY_NAME
	hotkey = KEY_M
	isInHotBar = true
	isTargeted = true

func perform(args, internal = false):	
	stuckAccumulator = 0.0
	stuckWait = 0.0
	
	if !internal && ownerEntity.has_node("ConfirmSound") && ownerEntity.team == Entity.TEAM_PLAYER:
		if !ownerEntity.get_node("ConfirmSound").playing:
			ownerEntity.get_node("ConfirmSound").play()

	if !internal:
		ownerEntity.currentAction = self
		
	if need_to_move(args["target"]):
		currentTarget = args["target"]
		return true
	else:
		 return false
	
func need_to_move(target):
	var targetPosition
	if target is Vector2:
		targetPosition = target
	elif target is Entity:
		targetPosition = target.position

	return targetPosition.distance_to(ownerEntity.position) > distanceApproximation
	
# TODO: add simple avoidance behaviour: is entity is stuck moving, try to move
# to a random close position, and the continue main move
func process(delta):
	if currentTarget:
		
		stuckWait -= delta
		if stuckWait > 0:
			return
			
		var targetPosition
		if currentTarget is Vector2:
			targetPosition = currentTarget
		elif currentTarget is Entity:
			targetPosition = currentTarget.position
			
			
		if targetPosition.distance_to(ownerEntity.position) > distanceApproximation:
			var oldPos = ownerEntity.position
			var dir = targetPosition - ownerEntity.position
			ownerEntity.move_and_slide(dir.normalized() * speed, Vector2(0, 0), false, 2)
			for i in range(ownerEntity.get_slide_count()):
				var coll = ownerEntity.get_slide_collision(i)
				var target = (coll as KinematicCollision2D).collider
				if target is Entity:
					if currentTarget is Entity && target == currentTarget:
						currentTarget = null
					if target.type == Entity.TYPE_UNIT:
						target.move_and_slide(coll.normal * -1 * speed / 4, Vector2(0, 0), false, 1)
					
			var diffX = ownerEntity.position.x - oldPos.x
			var diff = oldPos.distance_to(targetPosition) - ownerEntity.position.distance_to(targetPosition)
			var threshold = speed * delta * 0.2
			if ownerEntity.isSelected:
				pass
			if diff > threshold:
				stuckAccumulator -= diff * 0.5 / (speed * delta)
				if stuckAccumulator < 0:
					stuckAccumulator = 0
					
				if diffX > 0.2:
					ownerEntity.set_look_direction(Entity.LOOK_RIGHT)
				elif diffX < -0.2:
					ownerEntity.set_look_direction(Entity.LOOK_LEFT)
			else:
				if ownerEntity.isSelected:
					pass
				stuckAccumulator += 0.15
							
			if ownerEntity.animationPlayer.current_animation != "Walk":
				ownerEntity.animationPlayer.play("Walk")
				
			ownerEntity.z_index = ownerEntity.position.y
		else:
			currentTarget = null
			
	if !currentTarget:
		cancel()
		
	if stuckAccumulator >= 1:
		stuckWait = stuckTimeout
		stuckAccumulator = 0
		if ownerEntity.animationPlayer.current_animation == "Walk":
			ownerEntity.animationPlayer.stop(true)

func cancel():
	currentTarget = null
	# stuckAccumulator = 0.0
	if ownerEntity.currentAction == self:
		ownerEntity.currentAction = null
		
	if ownerEntity.animationPlayer.current_animation == "Walk":
		ownerEntity.animationPlayer.stop()
