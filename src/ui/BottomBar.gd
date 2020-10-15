extends HBoxContainer

class_name BottomBar

var level setget _set_level
onready var actionPanel = $ActionPanel

func _set_level(value):
	level = value
	level.currentSelection.connect("new_selection", self, "_on_selection_changed")
	
func _on_selection_changed(newSelection, oldSelection):
	clear_buttons()
	
	var newActions = {}
	
	for entity in newSelection:
		for cap in entity.capabilities:
			if !newActions.has(cap):
				newActions[cap] = entity.get_capability(cap)
				
	make_buttons(newActions)
				
func make_buttons(actions):
	var i = 1
	for act in actions:
		var button = make_button(actions[act])
		var panelName = "GridContainer/Action" + String(i)
		actionPanel.get_node(panelName).add_child(button)
		
func make_button(action):
	var button = ActionButton.new()
	button.capability = action
	button.connect("pressed", self, "_on_action_button_pressed", [button])
	return button

func _on_action_button_pressed(button):
	print("Pressed action ", button.capability.capabilityName)

func clear_buttons():
	for actionButtonPanel in actionPanel.get_node("GridContainer").get_children():
		if actionButtonPanel.get_child_count() > 0:
			actionButtonPanel.remove_child(actionButtonPanel.get_child(0))
