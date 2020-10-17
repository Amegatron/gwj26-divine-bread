extends PanelContainer

class_name ActionsBaloon

onready var container = $VBoxContainer/ContentContainer/MarginContainer setget , _get_container
onready var tooltipContainer = $VBoxContainer/TooltipContainer setget , _get_tooltip_container

func _ready():
	pass

func _get_container():
	if !container:
		container = get_node("VBoxContainer/ContentContainer/MarginContainer")
	
	return container
	
func _get_tooltip_container():
	if !tooltipContainer:
		tooltipContainer = get_node("VBoxContainer/ContentContainer/MarginContainer")
		
	return tooltipContainer
	
func set_baloon_content(value):
	if self.container:
		_clear_baloon_content()
		set_baloon_tooltip(null)
		container.add_child(value)
		if value.has_signal("show_tooltip"):
			value.connect("show_tooltip", self, "set_baloon_tooltip")
	
func _clear_baloon_content():
	if self.container:
		var children = container.get_children()
		for child in children:
			if child.has_signal("show_tooltip"):
				child.disconnect("show_tooltip", self, "set_baloon_tooltip")
			container.remove_child(child)

func set_baloon_tooltip(value):
	for node in self.tooltipContainer.get_children():
		tooltipContainer.remove_child(node)
		
	if value:
		tooltipContainer.add_child(value)
		tooltipContainer.visible = true
	else:
		tooltipContainer.visible = false
