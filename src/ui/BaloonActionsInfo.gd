extends HBoxContainer

class_name ActionInfos

func add_capability(cap):
	var icon = _create_action_icon(cap)
	add_child(icon)
	
func _create_action_icon(cap):
	var icon = load("res://scenes/ui/ActionIcon.tscn").instance()
	icon.icon = load(cap.icon)
	icon.hotkey = cap.hotkey
	return icon
