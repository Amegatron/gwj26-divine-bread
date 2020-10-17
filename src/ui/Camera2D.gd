extends Camera2D

export var speed = 10

func _input(event):
	if event is InputEventMouseButton:
		var pos = get_camera_position()
		if event.button_index == BUTTON_WHEEL_DOWN:
			pos.x += speed
			if pos.x > limit_right - get_viewport().size.x:
				pos.x = limit_right - get_viewport().size.x
			position = pos
		elif event.button_index == BUTTON_WHEEL_UP:
			pos.x -= speed
			if pos.x < 0:
				pos.x = 0
			position = pos
