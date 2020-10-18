extends Node2D

var currentSelection

onready var entities = $MapContainer/Entities
onready var canvasLayer = $CanvasLayer
onready var gameManager = $GameManager
onready var camera = $Camera2D

var ai

var currentHandAction

var leftBorder = 0
var rightBorder = 2400
var upperBorder = 200
var lowerBorder = 600

signal entity_added(entity)
signal entity_died(entity)

func _ready():
	var unit
	
	gameManager.level = self
	gameManager.add_team(Entity.TEAM_PLAYER)
	gameManager.add_team(Entity.TEAM_ENEMY)
	
	gameManager.get_team_resource(Entity.TEAM_PLAYER).set_resource_by_type(TeamResources.TYPE_BREADFORCE, 10)
	gameManager.get_team_resource(Entity.TEAM_ENEMY).set_resource_by_type(TeamResources.TYPE_BREADFORCE, 10)
		
	_init_entities()
	
	ai = AI.new()
	ai.gameManager = gameManager
	ai.cave = $MapContainer/Entities/EnemyCave
	ai.monument = $MapContainer/Entities/MonumentEnemy
	ai.enemyMonument = $MapContainer/Entities/Monument
	ai.level = self
	ai.team = Entity.TEAM_ENEMY
	ai.mapPosition = AI.MAP_POSITION_RIGHT
	ai.alarmZone = $MapContainer/EnemyAlarmZone
	add_child(ai)
		
	for i in range(4):
		unit = UnitFactory.createClubman(Entity.TEAM_PLAYER)
		unit.position = Vector2(500, 350 + i * 30)
		add_entity(unit)
		
	for i in range(4):
		unit = UnitFactory.createClubman(Entity.TEAM_ENEMY)
		unit.position = Vector2(1900, 350 + i * 30)
		add_entity(unit)
	
	currentSelection = Selection.new()
	currentSelection.level = self
	
	ai.start()

func _init_entities():
	for ent in entities.get_children():
		if ent is Entity:
			ent.level = self

	var cave = $MapContainer/Entities/PlayerCave
	cave.team = Entity.TEAM_PLAYER
	_init_cave(cave)
		
	cave = $MapContainer/Entities/EnemyCave
	cave.team = Entity.TEAM_ENEMY
	_init_cave(cave)
	
	var monument = $MapContainer/Entities/Monument
	monument.team = Entity.TEAM_PLAYER
	monument.defaultTargetAction = "Pray"
	_init_monument(monument)

	monument = $MapContainer/Entities/MonumentEnemy
	monument.team = Entity.TEAM_ENEMY
	_init_monument(monument)

func _init_cave(cave):
	var cap = ProduceClubmanCabability.new()
	cap.affectedByBonuses = ["HouseUpgradesBonus"]
	cap.hotkey = KEY_C
	cave.add_capability(cap)
	
	cap = HouseUpgradesBonusCapability.new()
	cave.add_capability(cap)

	cap = UpgradeHouseCapability.new()
	cap.hotkey = KEY_U
	cave.add_capability(cap)

func _init_monument(monument):
	var cap = GenerateBreadCapability.new()
	cap.affectedByBonuses = ["PrayableBonus"]
	monument.add_capability(cap)
	
	cap = TakeDamageCapability.new()
	monument.add_capability(cap)
	
	cap = ResearchStoneMasterCapability.new()
	cap.affectedByBonuses = ["PrayableBonus"]
	monument.add_capability(cap)
	
	cap = PrayableCapability.new()
	monument.add_capability(cap)
	
	cap = UpgradeMonumentCapability.new()
	cap.affectedByBonuses = ["PrayableBonus"]
	monument.add_capability(cap)
	
	cap = PrayableBonusCapability.new()
	monument.add_capability(cap)	

func get_capability_by_hotkey_in_selection(scancode):
	if currentSelection.selectedEntities.size() > 0:
		var entity = currentSelection.selectedEntities[0]
		if entity:
			for capName in entity.capabilities:
				var cap = entity.get_capability(capName)
				if cap.hotkey == scancode:
					return cap
	else:
		return null
	
func _input(event):		
	if event is InputEventKey:
		if event.scancode == KEY_F && event.is_pressed():
			OS.window_fullscreen = !OS.window_fullscreen
		
		if event.scancode == KEY_ESCAPE && currentHandAction:
			currentHandAction = null
		else:
			var cap = get_capability_by_hotkey_in_selection(event.scancode)
			if cap:
				if cap.isTargeted:
					currentHandAction = cap.capabilityName
				else:
					currentSelection.send_action_to_entities_by_hotkey(event.scancode, {})
					
		if event.scancode == KEY_ALT:
			for ent in entities.get_children():
				if ent.has_node("HealthBar"):
					if event.is_pressed():
						ent.get_node("HealthBar").visible = true
					elif !ent.isSelected:
						ent.get_node("HealthBar").visible = false
						
		if event.is_pressed():
			if event.scancode == KEY_F1 || event.scancode == KEY_HOME:
				camera.position = Vector2(leftBorder, 0)
			elif event.scancode == KEY_F4 || event.scancode == KEY_END:
				camera.position = Vector2(rightBorder - get_viewport().size.x, 0)
			
	var proximity = max(0, (currentSelection.selectedEntities.size() - 1) * 10)
	if event is InputEventMouse:
		var globalEventPos = get_global_mouse_position()
		if event.button_mask & BUTTON_LEFT:
			if !currentHandAction:
				if event.is_pressed():
					if !currentSelection.selectionStartPos:
						currentSelection.startSelection(globalEventPos)
				else:
					if currentSelection.selectionStartPos:
						currentSelection.continueSelection(globalEventPos)
			else:
				var target = get_global_mouse_position()
				
				var testEntity = get_entity_at_position(globalEventPos)
				if testEntity:
					target = testEntity
					
				currentSelection.send_action_to_entities(currentHandAction, {"target": target, "proximity": proximity})
				currentHandAction = null		
		elif currentSelection.selectionStartPos:
			var append = event.shift
			if currentSelection.selectionStartPos:
				currentSelection.endSelection(globalEventPos, append)
			
		if event.button_mask & BUTTON_RIGHT:
			if event.is_pressed():
				var entity = get_entity_at_position(globalEventPos)
				if entity:
					if entity.team == Entity.TEAM_ENEMY:
						currentSelection.send_action_to_entities("Attack", {"target": entity, "proximity": proximity})
					elif entity.defaultTargetAction:
						currentSelection.send_action_to_entities(entity.defaultTargetAction, {"target": entity, "proximity": proximity})
				else:
					if globalEventPos.y < 230:
						globalEventPos.y = 230
						
					currentSelection.send_action_to_entities("Move", {"target": globalEventPos, "proximity": proximity})

func get_entity_at_position(pos):	
	var ourShape = RectangleShape2D.new()
	ourShape.extents = Vector2(1, 1)
	var ourTransform = Transform2D(0, pos)

	var ents = entities.get_children()
	for obj in ents:
		if obj is Entity and obj.has_node("SelectionArea"):
			var area = obj.get_node("SelectionArea")
			for shapeIndex in range(area.shape_owner_get_shape_count(0)):
				var shape = area.shape_owner_get_shape(0, shapeIndex)
				var shapeTransform = area.shape_owner_get_transform(0) * area.global_transform
				
				if shape.collide(shapeTransform, ourShape, ourTransform):
					return obj
				
	return null

func add_entity(entity):
	if entity is Entity:
		entity.level = self
		entities.add_child(entity)
		entity.connect("died", self, "_on_entity_died", [entity])
		emit_signal("entity_added", entity)

func _on_entity_died(entity):
	if entity.isSelected:
		entity.isSelected = false
		currentSelection.remove_from_selection(entity)
		
	emit_signal("entity_died", entity)
