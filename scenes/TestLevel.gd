extends Node2D

var currentSelection

onready var entities = $Entities

var currentHandAction

func _ready():
	var unit
	
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

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_A:
			currentHandAction = "Attack"
		elif event.scancode == KEY_ESCAPE:
			currentHandAction = null
			
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
				currentSelection.send_action_to_entities(currentHandAction, {"target": event.position})
				currentHandAction = null		
		elif currentSelection.selectionStartPos:
			if currentSelection.selectionStartPos:
				currentSelection.endSelection(event.position)
			
		if event.button_mask & BUTTON_RIGHT:
			if event.is_pressed() && currentSelection.selectedEntities.size() > 0:
				var entity = currentSelection.get_entity_at_position(event.position)
				if entity:
					if entity.team == Entity.TEAM_ENEMY:
						currentSelection.send_action_to_entities("Attack", {"target": entity})
					elif entity.defaultTargetAction:
						currentSelection.send_action_to_entities(entity.defaultTargetAction, {"target": entity})
				else:
					currentSelection.send_action_to_entities("Move", {"target": event.position})

func add_entity(entity):
	entities.add_child(entity)
