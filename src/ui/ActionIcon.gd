extends PanelContainer

class_name ActionIcon

onready var textureRect = $MarginContainer/VBoxContainer/TextureRect setget , _get_texture_rect
onready var label = $MarginContainer/VBoxContainer/Label setget , _get_label
onready var requirementsContainer = $MarginContainer/VBoxContainer/Requirements setget , _get_requirements_container

var icon setget _set_icon
var hotkey setget _set_hotkey
var isAvailable = true setget _set_is_available

func _ready():
	_set_icon(icon)
	_set_hotkey(hotkey)
	_set_is_available(isAvailable)

func _set_is_available(value):
	isAvailable = value
	
	if isAvailable:
		modulate = Color(1, 1, 1, 1)
	else:
		modulate = Color(1, 1, 1, 0.5)
	
func _set_icon(value):
	icon = value
	if textureRect:
		textureRect.texture = icon
	
func _set_hotkey(value):
	hotkey = value	
	if label:
		label.text = OS.get_scancode_string(hotkey)
		
func _get_requirements_container():
	if !requirementsContainer:
		requirementsContainer = get_node("MarginContainer/VBoxContainer/Requirements")
		
	return requirementsContainer

func _get_label():
	if !label:
		label = get_node("MarginContainer/VBoxContainer/Label")
		
	return label

func _get_texture_rect():
	if !textureRect:
		textureRect = get_node("MarginContainer/VBoxContainer/TextureRect")
		
	return textureRect
