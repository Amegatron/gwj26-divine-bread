extends Object

class_name TeamResources

var team setget , _get_team
var breadForce : int = 0 setget _set_breadforce
var houseCapacityMax : int = 10 setget _set_housecapacity_max
var houseCapacity : int = 0 setget _set_housecapacity
var monumentLevel : int = 1 setget _set_monument_level

signal resource_changed(type, oldValue, newValue)

const TYPE_BREADFORCE = "breadforce"
const TYPE_HOUSE_CAPACITY = "houseCapacity"
const TYPE_HOUSE_CAPACITY_MAX = "houseCapacityMax"
const TYPE_MONUMENT_LEVEL = "monumentLevel"

func _init(team):
	self.team = team

func _set_breadforce(value):
	var oldValue = breadForce
	breadForce = value
	if oldValue != value:
		emit_signal("resource_changed", TYPE_BREADFORCE, oldValue, value)
	
func _set_housecapacity_max(value):
	var oldValue = houseCapacityMax
	houseCapacityMax = value
	if oldValue != value:
		emit_signal("resource_changed", TYPE_HOUSE_CAPACITY_MAX, oldValue, value)

func _get_team():
	return team

func _set_housecapacity(value):
	var oldValue = houseCapacity
	houseCapacity = value
	if oldValue != value:
		emit_signal("resource_changed", TYPE_HOUSE_CAPACITY, oldValue, value)

func _set_monument_level(value):
	var oldValue = monumentLevel
	monumentLevel = value
	if oldValue != value:
		emit_signal("resource_changed", TYPE_MONUMENT_LEVEL, oldValue, value)

func get_resource_by_type(type):
	match type:
		TYPE_BREADFORCE:
			return breadForce
		TYPE_HOUSE_CAPACITY:
			return houseCapacity
		TYPE_HOUSE_CAPACITY_MAX:
			return houseCapacityMax
		TYPE_MONUMENT_LEVEL:
			return monumentLevel
	
	return 0

func set_resource_by_type(type, value):
	match type:
		TYPE_BREADFORCE:
			self.breadForce = value
		TYPE_HOUSE_CAPACITY:
			self.houseCapacity = value
		TYPE_HOUSE_CAPACITY_MAX:
			self.houseCapacityMax = value
		TYPE_MONUMENT_LEVEL:
			self.monumentLevel = value
		
