extends Node

class_name Capability

var capabilityName = ""
var isAvailable : bool
var isInHotBar : bool
var progress : float
var activeOnDeadEntity = false

var ownerEntity setget _set_owner;

func perform(args, internal = false):
	pass

func _set_owner(value):
	ownerEntity = value

func process(delta):
	pass

func cancel():
	pass
