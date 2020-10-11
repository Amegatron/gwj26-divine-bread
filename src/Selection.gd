extends Object

class_name Selection

var level setget _set_level

var selectionStartPos : Vector2
var selectedEntities = []
var selectionRect

signal new_selection(newSelectedEntities, oldSelectiedEntities)

func _set_level(value):
	level = value
	
func startSelection(pos):
	selectionStartPos = pos
	var rect = ReferenceRect.new()
	rect.editor_only = false
	rect.border_color = Color(0, 1, 0)
	rect.rect_position = pos
	rect.show_on_top = true
	selectionRect = rect
	level.add_child(rect)
	
func continueSelection(pos):
	var sPos = selectionStartPos
	var size = Vector2(0, 0)
	size.x = abs(pos.x - sPos.x)
	size.y = abs(pos.y - sPos.y)
	selectionRect.rect_size = size
	if pos.x < sPos.x:
		selectionRect.rect_position.x = pos.x
	if pos.y < sPos.y:
		selectionRect.rect_position.y = pos.y
			
func endSelection(pos):
	for entity in selectedEntities:
		if entity:
			entity.isSelected = false
		
	var oldSelectedEntities = selectedEntities
	
	var entities = level.get_node("Entities").get_children()
	var ourShape = RectangleShape2D.new()
	ourShape.extents = selectionRect.rect_size / 2
	var ourTransform = Transform2D(0, selectionRect.rect_position + ourShape.extents)

	var tmpSelection = {
		"units": [],
		"buildings": [],
	}
	
	for obj in entities:
		if obj is Entity && obj.has_node("SelectionArea"):
			var area = obj.get_node("SelectionArea")
			var shape = area.shape_owner_get_shape(0, 0)
			var shapeTransform = area.shape_owner_get_transform(0) * area.global_transform
			if ourShape.collide(ourTransform, shape, shapeTransform) && obj.team == Entity.TEAM_PLAYER:
				match obj.type:
					Entity.TYPE_UNIT:
						tmpSelection["units"].append(obj)
					Entity.TYPE_BUILDING:
						tmpSelection["buildings"].append(obj)
						
	if tmpSelection["units"].size() > 0:
		selectedEntities = tmpSelection["units"]
	elif tmpSelection["buildings"].size() > 0:
		selectedEntities = [tmpSelection["buildings"][0]]
	else:
		selectedEntities = []
	
	for entity in selectedEntities:
		entity.isSelected = true
	
	selectionRect.queue_free()
	selectionStartPos = Vector2(0, 0)
	
	emit_signal("new_selection", selectedEntities, oldSelectedEntities)
	
func get_entity_at_position(position):	
	var ourShape = RectangleShape2D.new()
	ourShape.extents = Vector2(1, 1)
	var ourTransform = Transform2D(0, position)

	var entities = level.get_node("Entities").get_children()
	for obj in entities:
		if obj is Entity and obj.has_node("SelectionArea"):
			var area = obj.get_node("SelectionArea")
			var shape = area.shape_owner_get_shape(0, 0)
			var shapeTransform = area.shape_owner_get_transform(0) * area.global_transform
			
			if shape.collide(shapeTransform, ourShape, ourTransform):
				return obj
				
	return null

func send_action_to_entities(action, args):
	for entity in selectedEntities:
		if entity:
			entity.perform_action(action, args)
