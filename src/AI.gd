extends Node

class_name AI

const MAP_POSITION_LEFT = "left"
const MAP_POSITION_RIGHT = "right"

var started = false
var gameManager
var level setget _set_level
var team
var cave setget _set_cave
var monument setget _set_monument
var enemyMonument
var mapPosition
var alarmZone : Area2D setget _set_alarm_zone

var tacticalDecisionDelay = 1.0
var tacticalDecisionTimer = 0.0

var teamResources
var stoneMasterResearched = false
var prayableCap : PrayableCapability

var ourUnits = []
var newComers = []

var timePassed = 0.0
var attackDelay = 120.0
var attackTimer = attackDelay
var defenderCounter = 0
var startedToAttack = false
var defendersSinceLastAttack = 0

func _set_alarm_zone(value):
	alarmZone = value
	
func _set_monument(value):
	monument = value
	prayableCap = monument.get_capability("Prayable")
	
func _set_cave(value):
	cave = value
	
func _set_level(value):
	level = value
	level.connect("entity_added", self, "_on_entity_added")
	level.connect("entity_died", self, "_on_entity_died")
	
func _on_entity_added(entity):
	if entity.team == team && entity.type == Entity.TYPE_UNIT:
		var cap = AIStateCapability.new()
		entity.add_capability(cap)
		ourUnits.append(entity)
		newComers.append(entity)
		
func _on_entity_died(entity):
	if entity.team == team && entity.type == Entity.TYPE_UNIT:
		var pos = ourUnits.find(entity)
		if pos >= 0:
			ourUnits.remove(pos)
		
func start():
	started = true
	teamResources = gameManager.get_team_resource(team)
	
func _ready():
	pass
	
func _process(delta):
	if !started:
		return

	timePassed += delta
	
	tacticalDecisionTimer += delta
	if tacticalDecisionTimer >= tacticalDecisionDelay:
		tacticalDecisionTimer -= tacticalDecisionDelay
		make_build_action()
		manage_units(delta)

func manage_units(delta):
	ensure_praying()
	move_newcomers()
	send_attack_if_needed(delta)
	
func send_attack_if_needed(delta):
	if startedToAttack:
		attackTimer += delta
		
	var defenderThreshold = 20
	
	if defenderCounter >= 5 && !startedToAttack || startedToAttack && attackTimer > attackDelay || defendersSinceLastAttack >= defenderThreshold:
		defendersSinceLastAttack = 0
		startedToAttack = true
		attackTimer = 0.0
		for unit in ourUnits:
			if unit && !unit.currentAction:
				unit.get_capability("AIState").state = AIStateCapability.STATE_ATTACKER
				unit.perform_action("Attack", {"target": enemyMonument, "wandering": true, "proximity": ourUnits.size() * 5})

func move_newcomers():
	for unit in newComers:
		if !unit.currentAction:
			var target = get_random_defending_position()
			if target:
				defenderCounter += 1
				defendersSinceLastAttack += 1
				unit.perform_action("Attack", {"target": target})
				unit.get_capability("AIState").state = AIStateCapability.STATE_DEFENDER
			
	newComers.clear()
		
func get_random_defending_position():
	if alarmZone:
		var shape = alarmZone.shape_owner_get_shape(0, 0)
		var shapeOwnerTansform = alarmZone.shape_owner_get_transform(0)
		if shape is RectangleShape2D:
			var finalTransform = shapeOwnerTansform * alarmZone.global_transform
			var pos = Vector2(shape.extents.x * (randf() * 2 - 1), shape.extents.y * (randf() * 2 - 1))
			pos = finalTransform.xform(pos)
			return pos
			
	return null

	
func ensure_praying():
	if prayableCap.currentPrayers < prayableCap.maxPrayers:
		var idleUnits = []
		for unit in ourUnits:
			if !unit.currentAction:
				var distance = unit.position.distance_to(monument.position)
				idleUnits.append({"distance": distance, "unit": unit})
		
		idleUnits.sort_custom(self, "_sort_by_distance")
		var counter = 0
		var needed = prayableCap.maxPrayers - prayableCap.currentPrayers
		for unit in idleUnits:
			unit["unit"].get_capability("AIState").state = AIStateCapability.STATE_PRAYER
			unit["unit"].perform_action("Pray", {"target": monument, "delay": 0.8})
			counter += 1
			if counter == needed:
				break
		
func _sort_by_distance(a, b):
	return a["distance"] < b["distance"]
	
func make_build_action():
	if get_res(TeamResources.TYPE_HOUSE_CAPACITY) < get_res(TeamResources.TYPE_HOUSE_CAPACITY_MAX):
		try_order_unit()
	elif get_res(TeamResources.TYPE_HOUSE_UPGRADES) == 0 && get_res(TeamResources.TYPE_MONUMENT_LEVEL) < 2 && !monument.currentAction:
		try_upgrade_monument()
	elif get_res(TeamResources.TYPE_HOUSE_UPGRADES) == 0:
		try_upgrade_cave()
	elif get_res(TeamResources.TYPE_HOUSE_UPGRADES) == 1 && !monument.currentAction:
		try_research_stone_master()
	elif get_res(TeamResources.TYPE_HOUSE_UPGRADES) < 3:
		try_upgrade_cave()
	elif get_res(TeamResources.TYPE_HOUSE_UPGRADES) == 3 && get_res(TeamResources.TYPE_MONUMENT_LEVEL) < 3 && !monument.currentAction:
		try_upgrade_monument()
	else:
		var caveFactor = floor(get_res(TeamResources.TYPE_HOUSE_UPGRADES)/3) + 2
		if get_res(TeamResources.TYPE_MONUMENT_LEVEL) < caveFactor && !monument.currentAction:
			try_upgrade_monument()
		elif !cave.currentAction:
			try_upgrade_cave()
		
func get_res(type):
	return teamResources.get_resource_by_type(type)
	
func try_order_unit():
	# TODO: add stone master
	if !cave.currentAction:
		var cap = cave.get_capability("ProduceClubman")
		if gameManager.are_requirements_met(cap.requirements, team):
			cave.perform_action("ProduceClubman", {})

func try_upgrade_monument():
	if !monument.currentAction:
		var cap = monument.get_capability("UpgradeMonument")
		if gameManager.are_requirements_met(cap.requirements, team):
			monument.perform_action("UpgradeMonument", {})

func try_upgrade_cave():
	if !cave.currentAction:
		var cap = cave.get_capability("UpgradeHouse")
		if gameManager.are_requirements_met(cap.requirements, team):
			cave.perform_action("UpgradeHouse", {})	

func try_research_stone_master():
	if !monument.currentAction:
		var cap = monument.get_capability("ResearchStoneMaster")
		if !cap:
			stoneMasterResearched = true
			return
			
		if gameManager.are_requirements_met(cap.requirements, team):
			monument.perform_action("ResearchStoneMaster", {})
