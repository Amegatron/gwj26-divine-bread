extends Camera2D

export var speed = 10

func _input(event):
	if event is InputEventMouseButton:
		var pos = get_camera_position()
		if event.button_index == BUTTON_WHEEL_DOWN:
			pos.x += speed
			position = pos
		elif event.button_index == BUTTON_WHEEL_UP:
			pos.x -= speed
			position = pos
