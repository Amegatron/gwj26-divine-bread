extends Node

class_name GameManager

var teamResources = {} setget _set_team_resources, _get_team_resources
var level setget _set_level

func add_team(team):
	if !teamResources.has(team):
		teamResources[team] = TeamResources.new(team)

func _set_level(value):
	level = value
	level.connect("entity_added", self, "_on_entity_added")
	level.connect("entity_died", self, "_on_entity_died")
	
func _on_entity_added(entity):
	if entity.type == Entity.TYPE_UNIT:
		var res = get_team_resource(entity.team)
		res.set_resource_by_type(TeamResources.TYPE_HOUSE_CAPACITY, res.get_resource_by_type(TeamResources.TYPE_HOUSE_CAPACITY) + entity.houseCapacityCost)

func _on_entity_died(entity):
	if entity.type == Entity.TYPE_UNIT:
		var res = get_team_resource(entity.team)
		res.set_resource_by_type(TeamResources.TYPE_HOUSE_CAPACITY, res.get_resource_by_type(TeamResources.TYPE_HOUSE_CAPACITY) - entity.houseCapacityCost)

func get_team_resource(team):
	if teamResources.has(team):
		return teamResources[team]
	else:
		return null

# empty getter/setter to deny access to a var
func _get_team_resources():
	pass

func _set_team_resources(value):
	pass

func are_requirements_met(requirements, team):
	if requirements.size() == 0:
		return true
		
	var res = get_team_resource(team)
	for req in requirements:
		if req.type == TeamResources.TYPE_HOUSE_CAPACITY:
			if req.amount > res.get_resource_by_type(TeamResources.TYPE_HOUSE_CAPACITY_MAX) - res.get_resource_by_type(TeamResources.TYPE_HOUSE_CAPACITY):
				return false
		else:
			if req.amount > res.get_resource_by_type(req.type):
				return false
	
	return true

func consume_requirements(requirements, team):
	if requirements.size() == 0:
		return
		
	var res = get_team_resource(team)
	for req in requirements:
		if req.isConsumed:
			res.set_resource_by_type(req.type, res.get_resource_by_type(req.type) - req.amount)
