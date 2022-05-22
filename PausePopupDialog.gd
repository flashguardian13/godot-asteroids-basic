extends PopupPanel

var is_game_active = false

func _ready():
	pass

func _input(event):
	if visible == false || !is_game_active:
		return
	
	if event is InputEventKey:
		var key_event : InputEventKey = event
		if key_event.pressed && !key_event.echo:
			if key_event.scancode == KEY_ESCAPE:
				get_parent().hide_game_menu()
				get_tree().set_input_as_handled()
