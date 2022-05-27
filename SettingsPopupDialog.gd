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
