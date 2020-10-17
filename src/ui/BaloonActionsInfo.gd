extends HBoxContainer

class_name ActionInfos

var capabilities = []

func add_capability(cap):
	capabilities.append(cap)
	var icon = _create_action_icon(cap)
	add_child(icon)
	
func _create_action_icon(cap):
	var icon = load("res://scenes/ui/ActionIcon.tscn").instance()
	icon.icon = load(cap.icon)
	icon.hotkey = cap.hotkey
	for req in cap.requirements:
		var reqInfo = _create_requirement_info(req)
		icon.requirementsContainer.add_child(reqInfo)
		
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
