extends Object

class_name PushGroup

var continuePushing = true

signal entity_added(entity)

func add_entity(entity):
	if continuePushing:
		emit_signal("entity_added", entity)
		
	return continuePushing
