extends HBoxContainer

var ignore_value_changes:bool = false
var bus_idx:int = -1

func _ready():
	pass

func set_bus(idx):
	bus_idx = idx
	$VolumeSlider.value = db2linear(AudioServer.get_bus_volume_db(bus_idx))
	print("slider for bus %s set to %s" % [bus_idx, $VolumeSlider.value])

func _on_HSlider_value_changed(value):
	if ignore_value_changes:
		return
	
	print("new value for slider of bus %s: %s" % [bus_idx, value])
	AudioServer.set_bus_volume_db(bus_idx, linear2db(value))
	print("bus %s volume set to %s" % [bus_idx, AudioServer.get_bus_volume_db(bus_idx)])
	
	ignore_value_changes = true
	$CooldownTimer.start()

func _on_CooldownTimer_timeout():
	ignore_value_changes = false
