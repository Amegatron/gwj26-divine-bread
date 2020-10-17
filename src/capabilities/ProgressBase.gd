extends Capability

class_name ProgressBaseCapability

var timeNeeded = 10
var progressDeltaCounter = 0

func _init():
	pass

func perform(args, internnal = false):
	if !ownerEntity.currentAction:
		ownerEntity.currentAction = self
		progressDeltaCounter = 0
		return true
	
	return false
		
func process(delta):
	if ownerEntity.currentAction == self:
		var actualIncrement = delta
		
		if ownerEntity.has_capability("Prayable"):
			var cap = ownerEntity.get_capability("Prayable")
			actualIncrement *= cap.get_prayer_bonus()
			
		progressDeltaCounter += actualIncrement
		if progressDeltaCounter >= timeNeeded:
			progressDeltaCounter -= timeNeeded
			ownerEntity.currentAction = null
			progress_finished()
			
func progress_finished():
	pass

func _get_progress():
	return progressDeltaCounter * 100 / timeNeeded 
