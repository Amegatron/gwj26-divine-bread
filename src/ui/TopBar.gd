extends PanelContainer

class_name TopBar

onready var level = get_parent().get_parent()
onready var gameManager
onready var breadforceIndicator = $MarginContainer/IndicatorsContainer/Breadforce
onready var houseCapacityIndicator = $MarginContainer/IndicatorsContainer/HouseCapacity
onready var monumentLevelIndicator = $MarginContainer/IndicatorsContainer/MonumentLevel

var teamResource

func _ready():
	level.connect("ready", self, "_on_level_ready")
	
func _on_level_ready():
	gameManager = level.gameManager
	
	teamResource = gameManager.get_team_resource(Entity.TEAM_PLAYER)
	teamResource.connect("resource_changed", self, "_on_resource_changed")
	
	_update_breadfoce()
	_update_house_capacity()
	_update_monument_level()	

func _on_resource_changed(resourceName, oldValue, newValue):
	match resourceName:
		TeamResources.TYPE_BREADFORCE:
			_update_breadfoce()
		TeamResources.TYPE_HOUSE_CAPACITY, TeamResources.TYPE_HOUSE_CAPACITY_MAX:
			_update_house_capacity()
		TeamResources.TYPE_MONUMENT_LEVEL:
			_update_monument_level()

func _update_breadfoce():
	breadforceIndicator.text = String(teamResource.breadForce)
	
func _update_house_capacity():
	houseCapacityIndicator.text = String(teamResource.houseCapacity) + "/" + String(teamResource.houseCapacityMax)
	
func _update_monument_level():
	monumentLevelIndicator.text = String(teamResource.monumentLevel)
