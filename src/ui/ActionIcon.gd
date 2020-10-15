extends VBoxContainer

class_name ActionIcon

onready var textureRect = $TextureRect
onready var label = $Label

var icon setget _set_icon
var hotkey setget _set_hotkey

func _ready():
	update_nodes()

func _set_icon(value):
	icon = value
	update_nodes()
	
func _set_hotkey(value):
	hotkey = value
	update_nodes()
	
func update_nodes():
	if textureRect:
		textureRect.texture = icon
		
	if label:
		label.text = OS.get_scancode_string(hotkey)
