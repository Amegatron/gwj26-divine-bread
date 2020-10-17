extends HBoxContainer

class_name RequirementRow

onready var textureRect = $Icon
onready var label = $Label

var icon setget _set_icon
var text setget _set_text

func _ready():
	_set_icon(icon)
	_set_text(text)

func _set_icon(value):
	icon = value
	if textureRect:
		textureRect.texture = icon
		
func _set_text(value):
	text = value
	if label:
		label.text = text
