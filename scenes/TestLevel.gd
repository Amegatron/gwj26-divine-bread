extends Node2D

var currentSelection

onready var entities = $MapContainer/Entities
onready var canvasLayer = $CanvasLayer

var currentHandAction

func _ready():
	var unit
	
	for ent in entities.get_children():
		if ent is Entity:
			ent.level = self
	
	var cap = ProduceUnitCapability.new()
	cap.capabilityName = "ProduceClubman"
	cap.timeNeeded = 10
	cap.hotkey = KEY_C
	cap.targetUnit = "Clubman"
	cap.icon = "res://images/icons/clubman.png"
	$MapContainer/Entities/Cave.add_capability(cap)
	
	for i in range(8):
		unit = UnitFactory.createClubman(Entity.TEAM_PLAYER)
		unit.position = Vector2(300 + randi() % 50, 250 + i*40)
		add_entity(unit)

	for i in range(8):
		unit = UnitFactory.createClubman(Entity.TEAM_ENEMY)
		unit.position = Vector2(800 + randi() % 50, 250 + i*40)
		add_entity(unit)
	
	currentSelection = Selection.new()
	currentSelection.level = self

func get_capability_by_hotkey_in_selection(scancode):
	if currentSelection.selectedEntities.size() > 0:
		var entity = currentSelection.selectedEntities[0]
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

	if event is InputEventMouse:
		if event.button_mask & BUTTON_LEFT:
			if !currentHandAction:
				if event.is_pressed():
					if !currentSelection.selectionStartPos:
						currentSelection.startSelection(event.position)
				else:
					if currentSelection.selectionStartPos:
						currentSelection.continueSelection(event.position)
			else:
				var target = event.global_position
				
				var testEntity = get_entity_at_position(event.global_position)
				if testEntity:
					target = testEntity
					
				currentSelection.send_action_to_entities(currentHandAction, {"target": target})
				currentHandAction = null		
		elif currentSelection.selectionStartPos:
			if currentSelection.selectionStartPos:
				currentSelection.endSelection(event.position)
			
		if event.button_mask & BUTTON_RIGHT:
			if event.is_pressed():
				var entity = get_entity_at_position(event.global_position)
				if entity:
					if entity.team == Entity.TEAM_ENEMY:
						currentSelection.send_action_to_entities("Attack", {"target": entity})
					elif entity.defaultTargetAction:
						currentSelection.send_action_to_entities(entity.defaultTargetAction, {"target": entity})
				else:
					currentSelection.send_action_to_entities("Move", {"target": event.global_position})

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
	entity.level = self
	entities.add_child(entity)
