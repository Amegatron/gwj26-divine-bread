extends ProgressBaseCapability

class_name ProduceUnitCapability

var targetUnit

func progress_finished():
	var unit = UnitFactory.createUnitByName(targetUnit, ownerEntity.team)
	if ownerEntity.has_node("ProduceArea"):
		var area = ownerEntity.get_node("ProduceArea")
		if area.shape_owner_get_shape_count(0) > 0:
			var shape = (area as Area2D).shape_owner_get_shape(0, 0)
			var transform = (area as Area2D).shape_owner_get_transform(0)
			if shape is RectangleShape2D:
				var finalTransform = transform * area.global_transform
				var pos = Vector2(shape.extents.x * (randf() * 2 - 1), shape.extents.y * (randf() * 2 - 1))
				pos = finalTransform.xform(pos)
				unit.position = pos
				ownerEntity.level.add_entity(unit)
