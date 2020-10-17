tool
extends PanelContainer

class_name ResourceIndicator

onready var textureRect = $HBoxContainer/TextureRect
onready var labelControl = $HBoxContainer/MarginContainer/Label

export var icon : StreamTexture setget _set_icon
export var text : String setget _set_text

func _ready():
	_set_icon(icon)
	_set_text(text)

func _set_icon(value):
	icon = value
	if textureRect:
		textureRect.texture = icon
	
func _set_text(value):
	text = value
	if labelControl:
		labelControl.text = text
