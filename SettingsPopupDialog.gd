extends PopupPanel

func _ready():
	var button_container = $MarginContainer/VBoxContainer
	for bid in ["BackButton"]:
		button_container.get_node(bid).connect("mouse_entered", $ButtonOverPlayer, "play")

func _input(event):
	if visible == false:
		return
	
	if event is InputEventKey:
		var key_event : InputEventKey = event
		if key_event.pressed && !key_event.echo:
			if key_event.scancode == KEY_ESCAPE:
				get_parent().hide_settings_menu()
				get_tree().set_input_as_handled()

func _on_BackButton_pressed():
	$ButtonClickPlayer.play()
	hide()

func _on_SettingsPopupDialog_about_to_show():
	var volume_sliders_container = $MarginContainer/VBoxContainer
	volume_sliders_container.get_node("MainVolumeSliderContainer").set_bus(AudioServer.get_bus_index("Master"))
	volume_sliders_container.get_node("MusicVolumeSliderContainer").set_bus(AudioServer.get_bus_index("Music"))
	volume_sliders_container.get_node("SoundVolumeSliderContainer").set_bus(AudioServer.get_bus_index("Sound"))
