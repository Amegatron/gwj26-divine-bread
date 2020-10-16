extends HBoxContainer

class_name ProgressInfo

var trackedCapability setget _set_capability

func set_icon(icon):
	$TextureRect.texture = icon

func _set_capability(value):
	trackedCapability = value
	$TextureRect.texture = load(value.icon)
	if trackedCapability is ProgressBaseCapability:
		_update_progress()
		
func _process(delta):
	_update_progress()

func _update_progress():
	$ProgressBar.value = trackedCapability.progress
