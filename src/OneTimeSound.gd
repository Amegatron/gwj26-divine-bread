extends Node2D

class_name OneTimeSound

func play(sound, ownerNode, positional = false):
	var audioPlayer
	if positional:
		audioPlayer = AudioStreamPlayer2D.new()
	else:
		audioPlayer = AudioStreamPlayer.new()
		
	audioPlayer.stream = load(sound)
	audioPlayer.autoplay = true
	audioPlayer.connect("finished", self, "_on_play_finished")
	add_child(audioPlayer)
	ownerNode.add_child(self)

func _on_play_finished():
	queue_free()
