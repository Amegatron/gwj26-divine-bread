extends PanelContainer

class_name ActionTooltip

onready var descriptionLabel = $MarginContainer/VBoxContainer/Description setget , _get_description_label
onready var requirementsContainer = $MarginContainer/VBoxContainer/HBoxContainer/Requirements setget , _get_requirements_container

var capability setget _set_capability

func _get_description_label():
	if !descriptionLabel:
		descriptionLabel = get_node("MarginContainer/VBoxContainer/Description")
		
	return descriptionLabel

func _get_requirements_container():
	if !requirementsContainer:
		requirementsContainer = get_node("MarginContainer/VBoxContainer/HBoxContainer/Requirements")
		
	return requirementsContainer

func _set_capability(value):
	capability = value
	self.descriptionLabel.text = capability.description
	capability.connect("requirements_changed", self, "_on_requirements_changed")
	_on_requirements_changed()
	
func _on_requirements_changed():
	for node in self.requirementsContainer.get_children():
		requirementsContainer.remove_child(node)
		
	for req in capability.requirements:
		var node = _create_requirement_node(req)
		requirementsContainer.add_child(node)
		
func _create_requirement_node(req):
	var node = load("res://scenes/ui/RequirementRow.tscn").instance()
	
	match req.type:
		TeamResources.TYPE_BREADFORCE:
			node.icon = load(IconResources.ICON_BREAD)
		TeamResources.TYPE_HOUSE_CAPACITY:
			node.icon = load(IconResources.ICON_HOUSE)
		TeamResources.TYPE_MONUMENT_LEVEL:
			node.icon = load(IconResources.ICON_MONUMENT)

	node.text = String(req.amount)
	
	return node
