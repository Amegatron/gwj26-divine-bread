extends Capability

class_name PushableCapability

var nextFramePushes = []
var currentFramePushes = []

var finalPush = Vector2(0, 0)
var currentGroups = []

func _init():
	capabilityName = "Pushable"
	
func get_current_frame_push():
	var finalPush = Vector2(0, 0)
	var currentGroups = {}
	var counter = 0

	if currentFramePushes.size() > 10:
		pass
		
	for push in currentFramePushes:
		counter += 1
		finalPush += push["dir"]
		for grp in push["groups"]:
			if grp.continuePushing:
				currentGroups[grp] = grp
				
	if currentGroups.size() > 0 && counter > 0:
		if counter > 0:
			finalPush /= counter
			return [finalPush, currentGroups]
	else:
		return [Vector2(0, 0), []]

func process_physics(delta):		
	var ret = get_current_frame_push()
	finalPush = ret[0]
	currentGroups = ret[1]	
	currentFramePushes = nextFramePushes
	nextFramePushes = []
				
func queue_push(dir, pushGroups, by):		
	nextFramePushes.append({"dir": dir, "groups": pushGroups, "by": by})
