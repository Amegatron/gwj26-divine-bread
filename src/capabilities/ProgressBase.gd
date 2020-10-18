extends Capability

class_name ProgressBaseCapability

var timeNeeded = 10
var progressDeltaCounter = 0
# strings: names of Bonus capabilities
var affectedByBonuses = []

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
					
		actualIncrement *= get_total_bonus()
			
		progressDeltaCounter += actualIncrement
		if progressDeltaCounter >= timeNeeded:
			progressDeltaCounter -= timeNeeded
			ownerEntity.currentAction = null
			progress_finished()
			
func get_total_bonus():
	var bonus = 1
	for bonusName in affectedByBonuses:
		if ownerEntity.has_capability(bonusName):
			var cap = ownerEntity.get_capability(bonusName)
			if cap is BonusCapability:
				bonus += cap.get_bonus() - 1
				
	return bonus
	
func progress_finished():
	pass

func _get_progress():
	return progressDeltaCounter * 100 / timeNeeded 
