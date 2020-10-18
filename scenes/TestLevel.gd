extends Node2D

var currentSelection

onready var entities = $MapContainer/Entities
onready var canvasLayer = $CanvasLayer
onready var gameManager = $GameManager
onready var camera = $Camera2D

var currentHandAction

signal entity_added(entity)
signal entity_died(entity)

func _ready():
	var unit
	
	gameManager.level = self
	gameManager.add_team(Entity.TEAM_PLAYER)
	gameManager.add_team(Entity.TEAM_ENEMY)
	
	gameManager.get_team_resource(Entity.TEAM_PLAYER).set_resource_by_type(TeamResources.TYPE_BREADFORCE, 10)
	
	_init_entities()
		
	for i in range(25):
		unit = UnitFactory.createClubman(Entity.TEAM_PLAYER)
		unit.position = Vector2(500 + randi()%200, 350 + randi()%100)
		add_entity(unit)
		
	for i in range(25):
		unit = UnitFactory.createClubman(Entity.TEAM_ENEMY)
		unit.position = Vector2(1200 + randi() % 200, 350 + randi()%100)
		add_entity(unit)
		unit.perform_action("Attack", {"target": $MapContainer/Entities/Monument, "wandering": true})
	
	currentSelection = Selection.new()
	currentSelection.level = self

func _init_entities():
	for ent in entities.get_children():
		if ent is Entity:
			ent.level = self

	var cap = ProduceClubmanCabability.new()
	var cave = $MapContainer/Entities/Cave
	cap.affectedByBonuses = ["HouseUpgradesBonus"]
	cap.hotkey = KEY_C
	cave.add_capability(cap)
	
	cap = HouseUpgradesBonusCapability.new()
	cave.add_capability(cap)

	cap = UpgradeHouseCapability.new()
	cap.hotkey = KEY_U
	cave.add_capability(cap)
		
	var monument = $MapContainer/Entities/Monument
	cap = GenerateBreadCapability.new()
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
					
				currentSelection.send_action_to_entities(currentHandAction, {"target": target})
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
						currentSelection.send_action_to_entities("Attack", {"target": entity})
					elif entity.defaultTargetAction:
						currentSelection.send_action_to_entities(entity.defaultTargetAction, {"target": entity})
				else:
					if globalEventPos.y < 230:
						globalEventPos.y = 230
						
					currentSelection.send_action_to_entities("Move", {"target": globalEventPos})

func get_entity_at_position(pos):	
	var ourShape = RectangleShape2D.new()
	ourShape.extents = Vector2(1, 1)
	var ourTransform = Transform2D(0, pos)

	var ents = entities.get_children()
	for obj in ents:
		if obj is Entity and obj.has_node("SelectionArea"):
			var area = obj.get_node("SelectionArea")
			var shape = area.shape_owner_get_shape(0, 0)
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
