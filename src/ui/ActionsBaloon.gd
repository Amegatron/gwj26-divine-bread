extends PanelContainer

class_name ActionsBaloon

func set_baloon_content(value):
	var container = get_node("MarginContainer")
	if container:
		_clear_baloon_content()
		container.add_child(value)
	
func _clear_baloon_content():
	var container = get_node("MarginContainer")
	if container:
		var children = container.get_children()
		for child in children:
			container.remove_child(child)	
