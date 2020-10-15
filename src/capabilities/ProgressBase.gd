extends Capability

class_name ProgressBaseCapability

var timeNeeded = 2
var progressDeltaCounter = 0

func _init():
	pass

func perform(args, internnal = false):
	if !ownerEntity.currentAction:
		ownerEntity.currentAction = self
		progressDeltaCounter = 0
		
func process(delta):
	if ownerEntity.currentAction == self:
		progressDeltaCounter += delta
		if progressDeltaCounter >= timeNeeded:
			progressDeltaCounter = 0
			ownerEntity.currentAction = null
			progress_finished()
			
func progress_finished():
	pass

func _get_progress():
	return progressDeltaCounter * 100 / timeNeeded 
