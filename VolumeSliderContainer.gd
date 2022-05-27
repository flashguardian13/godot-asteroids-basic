extends HBoxContainer

var ignore_value_changes:bool = false
var bus_idx:int = -1

func _ready():
	pass

func set_bus(idx):
	bus_idx = idx
	$VolumeSlider.value = db2linear(AudioServer.get_bus_volume_db(bus_idx))

func _on_HSlider_value_changed(value):
	if ignore_value_changes:
		return
	
	AudioServer.set_bus_volume_db(bus_idx, linear2db(value))
	
	ignore_value_changes = true
	$CooldownTimer.start()

func _on_CooldownTimer_timeout():
	ignore_value_changes = false
