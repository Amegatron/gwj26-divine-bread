extends Node2D

var currentSelection

onready var entities = $Entities

func _ready():
	var unit
	
	for i in range(8):
		unit = UnitFactory.createClubman(Entity.TEAM_PLAYER)
		unit.position = Vector2(300 + randi() % 50, 250 + i*40)
		add_entity(unit)

#	unit = UnitFactory.createClubman(Entity.TEAM_PLAYER)
#	unit.position = Vector2(330, 450)
#	add_entity(unit)
#
#	unit = UnitFactory.createClubman(Entity.TEAM_PLAYER)
#	unit.position = Vector2(300, 400)
#	add_entity(unit)
	
	for i in range(8):
		unit = UnitFactory.createClubman(Entity.TEAM_ENEMY)
		unit.position = Vector2(800 + randi() % 50, 250 + i*40)
		add_entity(unit)
	
#	unit = UnitFactory.createClubman(Entity.TEAM_ENEMY)
#	unit.position = Vector2(1000, 350)
#	add_entity(unit)
#
#	unit = UnitFactory.createClubman(Entity.TEAM_ENEMY)
#	unit.position = Vector2(1000, 450)
#	add_entity(unit)
	
	# unit.perform_action("Move", {"target": Vector2(500, 500)})
	currentSelection = Selection.new()
	currentSelection.level = self

func _input(event):
	if event is InputEventMouse:
		if event.button_mask & BUTTON_LEFT:
			if event.is_pressed():
				if !currentSelection.selectionStartPos:
					currentSelection.startSelection(event.position)
			else:
				if currentSelection.selectionStartPos:
					currentSelection.continueSelection(event.position)
		elif currentSelection.selectionStartPos:
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
					currentSelection.send_action_to_entities("Attack", {"target": event.position})

func add_entity(entity):
	entities.add_child(entity)
