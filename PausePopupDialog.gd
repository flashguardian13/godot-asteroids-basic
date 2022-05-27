extends PopupPanel

var is_game_active = false

func _ready():
	var button_container = $VBoxContainer/VBoxContainer
	for bid in ["ResumeButton", "NewButton", "SettingsButton", "QuitButton"]:
		button_container.get_node(bid).connect("mouse_entered", $SoundPlayer, "play")

func _input(event):
	if visible == false || !is_game_active:
		return
	
	if event is InputEventKey:
		var key_event : InputEventKey = event
		if key_event.pressed && !key_event.echo:
			if key_event.scancode == KEY_ESCAPE:
				get_parent().hide_game_menu()
				get_tree().set_input_as_handled()
