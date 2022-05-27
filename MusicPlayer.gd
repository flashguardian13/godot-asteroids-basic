extends AudioStreamPlayer

func fade_in(song):
	$Tween.interpolate_property(self, "volume_db", -60, 0, 3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	stream = song
	volume_db = -60
	play()

func fade_out():
	$Tween.interpolate_property(self, "volume_db", 0, -60, 3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _on_tween_completed(object, key):
	if volume_db <= -60:
		stop()
