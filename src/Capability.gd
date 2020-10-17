extends Node

class_name Capability

var capabilityName = ""
var isAvailable = true setget _set_is_available, _get_is_available
var isInHotBar = false
var progress : float = 0.0 setget , _get_progress
var activeOnDeadEntity = false
var hotkey
var isTargeted = false
var icon setget , _get_icon
var requirements = [] setget _set_requirements , _get_requirements
var description = ""

var ownerEntity setget _set_owner;

signal requirements_changed

func perform(args, internal = false):
	pass

func _set_owner(value):
	ownerEntity = value

func process(delta):
	pass

func cancel():
	pass

func _get_icon():
	return icon

func _set_is_available(value):
	isAvailable = value
	
func _get_is_available():
	return isAvailable

func _get_progress():
	return progress

func _get_requirements():
	return requirements

func _set_requirements(value):
	requirements = value
	emit_signal("requirements_changed")
