extends AnimationPlayer

func play(animation = "default", custom_blend = -1, custom_speed = 1.0, from_end = false):
	print("Play: ", animation)
	.play(animation, custom_blend, custom_speed, from_end)
	
func stop(reset = true):
	print("Stop")
	.stop(reset)
