extends Object

class_name PushGroup

var continuePushing = true
var timeOut = 0.2

var addedEntities = {}

signal entity_added(entity)
	
func process(delta):
	var deferRemove = []
	
	for ent in addedEntities:
		if ent:
			addedEntities[ent] += delta
			if addedEntities[ent] > timeOut:
				deferRemove.append(ent)
			
	for dr in deferRemove:
		addedEntities.erase(dr)
		
func add_entity(entity):
	if continuePushing && !addedEntities.has(entity):
		addedEntities[entity] = 0.0
		emit_signal("entity_added", entity)
		return true
	else:
		return false
