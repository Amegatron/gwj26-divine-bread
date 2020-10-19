extends Capability

class_name MoveCapability

var speed = 100

var currentTarget

var stuckAccumulator = 0.0
var stuckWait = 0.0
var stuckTimeout = 1
var noPushCounter = 0
var pushGroup

const CAPABILITY_NAME = "Move"
const NO_PUSH_FRAMES_LIMIT = 10

func _init():
	capabilityName = CAPABILITY_NAME
	hotkey = KEY_M
	isInHotBar = true
	isTargeted = true

func perform(args, internal = false):	
	stuckAccumulator = 0.0
	stuckWait = 0.0
	noPushCounter = 0
	pushGroup = null
	
#	if !internal && ownerEntity.has_node("ConfirmSound") && ownerEntity.team == Entity.TEAM_PLAYER:
#		if !ownerEntity.get_node("ConfirmSound").playing:
#			ownerEntity.get_node("ConfirmSound").play()

	if !internal:
		if ownerEntity.currentAction && ownerEntity.currentAction != self:
			ownerEntity.currentAction.cancel()
		ownerEntity.currentAction = self
		
	currentTarget = args["target"]
	
# TODO: add simple avoidance behaviour: is entity is stuck moving, try to move
# to a random close position, and the continue main move
func process_physics(delta):
	var targetPosition = Vector2(0, 0)
	
	if currentTarget:			
#		stuckWait -= delta
#		if stuckWait > 0:
#			return
			
		if ownerEntity.isSelected:
			pass
			
		if currentTarget is Vector2:
			targetPosition = currentTarget
		elif currentTarget is Entity:
			targetPosition = currentTarget.position
			
		var oldPos = ownerEntity.position
		var dir = targetPosition - ownerEntity.position
		if dir.length() > 1:
			ownerEntity.move_and_slide(dir.normalized() * speed, Vector2(0, 0), false, 2)
			if ownerEntity.get_slide_count() == 0:
				if pushGroup:
					noPushCounter += 1
					if noPushCounter >= NO_PUSH_FRAMES_LIMIT:
						pushGroup.continuePushing = false
						pushGroup = null
						noPushCounter = 0
			elif !pushGroup:
				pushGroup = PushGroup.new()
				pushGroup.connect("entity_added", self, "_on_entity_added_to_push_group", [pushGroup])
				if !pushGroup.add_entity(ownerEntity):
					return
			
			for i in range(ownerEntity.get_slide_count()):
				var coll = ownerEntity.get_slide_collision(i)
				var target = (coll as KinematicCollision2D).collider
				if target is Entity:
					if !pushGroup.add_entity(target):
						return
						
					if pushGroup.continuePushing:
						var pushableCap = target.get_capability("Pushable")
						if pushableCap:
							pushableCap.queue_push(coll.normal * -1 * speed / 3, [pushGroup])
			
			var diffX = ownerEntity.position.x - oldPos.x
			if diffX > 0.2:
				ownerEntity.set_look_direction(Entity.LOOK_RIGHT)
			elif diffX < -0.2:
				ownerEntity.set_look_direction(Entity.LOOK_LEFT)

			if ownerEntity.animationPlayer.current_animation != "Walk":
				ownerEntity.animationPlayer.stop(true)
				ownerEntity.animationPlayer.play("Walk")
				
			ownerEntity.z_index = ownerEntity.position.y
		else:
			finished("close enough")
			return

	if !currentTarget:
		cancel()

func cancel():
	currentTarget = null
	stuckAccumulator = 0.0
	noPushCounter = 0
	if pushGroup:
		pushGroup.continuePushing = false
		pushGroup = null
		
	if ownerEntity.currentAction == self:
		ownerEntity.currentAction = null
		
	if ownerEntity.animationPlayer.current_animation == "Walk":
		ownerEntity.animationPlayer.stop()

func _on_entity_added_to_push_group(entity, grp):
	var reached = false
	
	if !pushGroup:
		print("WARNING: possible ghost pushGroup")
		
	if currentTarget is Entity && entity == currentTarget:
		reached = true
	elif currentTarget is Vector2 && entity is CollisionObject2D:
		var testShape = CircleShape2D.new()
		testShape.radius = 3
		var testTransform = Transform2D(0, currentTarget)
		
		var ownerTransform = entity.shape_owner_get_transform(0)
		var finalOwnerTransform = entity.global_transform * ownerTransform
		for i in range(entity.shape_owner_get_shape_count(0)):
			var shape = entity.shape_owner_get_shape(0, i)
			if shape.collide(finalOwnerTransform, testShape, testTransform):
				reached = true
				break
				
	if reached:
		finished("collision")

func queue_finished():
	pass
	
func finished(reason = "because"):
	cancel()
	print("Move finished: ", reason)
	emit_signal("finished")
