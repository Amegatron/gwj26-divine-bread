extends Capability

class_name MoveCapability

var speed = 100

var currentTarget
var distanceApproximation = 30

const CAPABILITY_NAME = "Move"

func _init():
	capabilityName = CAPABILITY_NAME

func perform(args, internal = false):
	if need_to_move(args["target"]):
		currentTarget = args["target"]
		if currentTarget is Entity:
			print("Moving to entity")
		elif currentTarget is Vector2:
			print("Moving to location")
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
	
func process(delta):
	if currentTarget:
		var targetPosition
		if currentTarget is Vector2:
			targetPosition = currentTarget
		elif currentTarget is Entity:
			targetPosition = currentTarget.position
			
			
		if targetPosition.distance_to(ownerEntity.position) > distanceApproximation:
			var oldPos = ownerEntity.position
			var dir = targetPosition - ownerEntity.position
			ownerEntity.move_and_slide(dir.normalized() * speed)
			for i in range(ownerEntity.get_slide_count()):
				var coll = ownerEntity.get_slide_collision(i)
				var target = (coll as KinematicCollision2D).collider
				if target is Entity && target.type == Entity.TYPE_UNIT:
					target.move_and_slide(coll.normal * -1 * speed / 4)
					
			var diff = ownerEntity.position.x - oldPos.x
			if diff > 0:
				ownerEntity.set_look_direction(Entity.LOOK_RIGHT)
			elif diff < 0:
				ownerEntity.set_look_direction(Entity.LOOK_LEFT)
				
			if ownerEntity.animationPlayer.current_animation != "Walk":
				ownerEntity.animationPlayer.play("Walk")
				
			ownerEntity.z_index = ownerEntity.position.y
		else:
			currentTarget = null
			
	if !currentTarget:
		cancel()

func cancel():
	currentTarget = null
	if ownerEntity.currentAction == self:
		ownerEntity.currentAction = null
		
	if ownerEntity.animationPlayer.current_animation == "Walk":
		ownerEntity.animationPlayer.stop()