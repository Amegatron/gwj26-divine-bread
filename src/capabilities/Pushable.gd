extends Capability

class_name PushableCapability

var nextFramePushes = []
var currentFramePushes = []

func _init():
	capabilityName = "Pushable"
	
func process_physics(delta):
	var finalPush = Vector2(0, 0)
	var currentGroups = {}
	var counter = 0
	for push in currentFramePushes:
		var grp = push["group"]
		if grp.continuePushing:
			counter += 1
			finalPush += push["dir"]
			currentGroups[push["group"]] = push["group"]
		
	if counter > 0:
		finalPush /= counter
		ownerEntity.move_and_slide(finalPush, Vector2(0, 0), false, 1)
		for i in range(ownerEntity.get_slide_count()):
			var coll = ownerEntity.get_slide_collision(i)
			var target = coll.collider
			if target is Entity:
				for grp in currentGroups:
					grp.add_entity(target)
					
				var pushableCap = target.get_capability(capabilityName)
				if pushableCap:
					pushableCap.queue_push(coll.normal * -1 * finalPush.length(), currentGroups.values())
					
	currentFramePushes = nextFramePushes
	nextFramePushes = []
				
func queue_push(dir, pushGroups):
	for grp in pushGroups:
		nextFramePushes.append({"dir": dir, "group": grp})
