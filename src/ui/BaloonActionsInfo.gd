extends HBoxContainer

class_name ActionInfos

var capabilities = {}

signal show_tooltip(value)

func add_capability(cap):
	capabilities[cap.capabilityName] = cap
	var icon = _create_action_icon(cap)
	add_child(icon)
	
func remove_capability(capName):
	if capabilities.has(capName):
		capabilities.erase(capName)
	
	for node in get_children():
		if node.capability.capabilityName == capName:
			remove_child(node)
			
func _on_icon_mouse_enter(icon):
	if icon.tooltip:
		emit_signal("show_tooltip", icon.tooltip)
	
func _on_icon_mouse_exit(icon):
	emit_signal("show_tooltip", null)

func _on_icon_gui_input(event, icon):
	if event is InputEventMouseButton:
		if event.is_pressed() && event.button_index == BUTTON_LEFT && icon.capability.ownerEntity.team == Entity.TEAM_PLAYER:
			icon.capability.ownerEntity.perform_action(icon.capability.capabilityName, {})

func _create_action_icon(cap):
	var icon = load("res://scenes/ui/ActionIcon.tscn").instance()
	icon.capability = cap
	
	icon.connect("mouse_entered", self, "_on_icon_mouse_enter", [icon])
	icon.connect("mouse_exited", self, "_on_icon_mouse_exit", [icon])
	icon.connect("gui_input", self, "_on_icon_gui_input", [icon])
		
	return icon

func _create_requirement_info(requirement):
	var reqInfo = load("res://scenes/ui/RequirementRow.tscn").instance()
	
	match requirement.type:
		TeamResources.TYPE_BREADFORCE:
			reqInfo.icon = load(IconResources.ICON_BREAD)
		TeamResources.TYPE_HOUSE_CAPACITY:
			reqInfo.icon = load(IconResources.ICON_HOUSE)
		TeamResources.TYPE_MONUMENT_LEVEL:
			reqInfo.icon = load(IconResources.ICON_MONUMENT)
			
	reqInfo.text = String(requirement.amount)
	
	return reqInfo
