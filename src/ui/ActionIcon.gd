extends PanelContainer

class_name ActionIcon

onready var textureRect = $MarginContainer/VBoxContainer/TextureRect setget , _get_texture_rect
onready var label = $MarginContainer/VBoxContainer/Label setget , _get_label

var capability setget _set_capability
var tooltip

func _ready():
	_set_capability(capability)

func _set_capability(cap):
	capability = cap
	_set_icon(load(cap.icon))
	_set_hotkey(cap.hotkey)

	tooltip = _create_tooltip()
	
func _set_is_available(value):
	if value:
		modulate = Color(1, 1, 1, 1)
	else:
		modulate = Color(1, 1, 1, 0.5)
	
func _set_icon(value):
	if textureRect:
		textureRect.texture = value
	
func _set_hotkey(value):
	if label:
		label.text = OS.get_scancode_string(value)
		
func _get_label():
	if !label:
		label = get_node("MarginContainer/VBoxContainer/Label")
		
	return label

func _get_texture_rect():
	if !textureRect:
		textureRect = get_node("MarginContainer/VBoxContainer/TextureRect")
		
	return textureRect

func _create_tooltip():
	var node = load("res://scenes/ui/ActionTooltip.tscn").instance()
	node.capability = capability
	
	return node
