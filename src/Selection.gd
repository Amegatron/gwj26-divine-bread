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
	rect.rect_position = level.get_viewport_transform().xform(pos)
	rect.show_on_top = true
	selectionRect = rect
	level.canvasLayer.add_child(rect)
	
func continueSelection(pos):
	var sPos = selectionStartPos
	var size = Vector2(0, 0)
	size.x = abs(pos.x - sPos.x)
	size.y = abs(pos.y - sPos.y)
	selectionRect.rect_size = size
	if pos.x < sPos.x || pos.y < sPos.y:
		var origin = level.get_viewport_transform().get_origin()
		var newPos = selectionRect.rect_position
		
		if pos.x < sPos.x:
			newPos.x = pos.x + origin.x
		if pos.y < sPos.y:
			newPos.y = pos.y + origin.y
			
		selectionRect.rect_position = newPos
			
func endSelection(pos, append = false):
	if !append:
		for entity in selectedEntities:
			if entity:
				entity.isSelected = false
		
	var oldSelectedEntities = selectedEntities
	
	var entities = level.entities.get_children()
	var ourShape = RectangleShape2D.new()
	ourShape.extents = selectionRect.rect_size / 2
	var ourTransform = Transform2D(0, level.get_viewport_transform().xform_inv(selectionRect.rect_position) + ourShape.extents)

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
						
	var deselect = true
	for tmp in tmpSelection["units"]:
		if !tmp.isSelected:
			deselect = false
			break

	if tmpSelection["units"].size() > 0:
		if selectedEntities.size() > 0 && selectedEntities[0].type == Entity.TYPE_UNIT && append:
			if deselect:
				for tmp in tmpSelection["units"]:
					if tmp.isSelected:
						tmp.isSelected = false
						selectedEntities.remove(selectedEntities.find(tmp))
					else:
						selectedEntities.append(tmp)
			else:
				for tmp in tmpSelection["units"]:
					if !tmp.isSelected:
						selectedEntities.append(tmp)
		elif !append || oldSelectedEntities.size() == 0:
			selectedEntities = tmpSelection["units"]
			
	elif tmpSelection["buildings"].size() > 0:
		if !append || oldSelectedEntities.size() == 0:
			selectedEntities = [tmpSelection["buildings"][0]]
	elif !append:
		selectedEntities = []

	emit_signal("new_selection", selectedEntities, oldSelectedEntities)
	
	for entity in oldSelectedEntities:
		if entity:
			entity.isSelected = false
	
	for entity in selectedEntities:
		entity.isSelected = true
	
	selectionRect.queue_free()
	selectionStartPos = Vector2(0, 0)

func remove_from_selection(entity):
	var pos = selectedEntities.find(entity)
	if pos >= 0:
		selectedEntities.remove(pos)

func send_action_to_entities(action, args):
	for entity in selectedEntities:
		if entity:
			entity.perform_action(action, args)
			
func send_action_to_entities_by_hotkey(hotkey, args):
	for entity in selectedEntities:
		entity.perform_action_by_hotkey(hotkey, args)
