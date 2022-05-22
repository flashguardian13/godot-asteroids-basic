extends Node2D

var game : Node2D
var gui : MarginContainer
var pause_popup : PopupPanel

var scheduled_calls : Array
var elapsed_time : float

func _ready():
	game = get_node("VBoxContainer/ViewportContainer/Viewport/Game")
	game.main = self
	gui = get_node("VBoxContainer/GUI")
	pause_popup = get_node("PausePopupDialog")
	
	game.connect("score_changed", gui, "display_score")
	game.connect("ship_count_changed", gui, "display_ships")
	game.connect("level_changed", gui, "display_level")
	game.connect("game_over", self, "on_game_over")
	
	gui.display_score(game.score)
	gui.display_ships(game.ships_remaining)
	gui.display_level(game.level)
	
	var button = pause_popup.get_node("VBoxContainer/VBoxContainer/NewButton")
	button.connect("pressed", self, "on_new_pressed")
	button = pause_popup.get_node("VBoxContainer/VBoxContainer/PlayButton")
	button.connect("pressed", self, "on_play_pressed")
	button = pause_popup.get_node("VBoxContainer/VBoxContainer/QuitButton")
	button.connect("pressed", self, "on_quit_pressed")
	
	show_game_menu()

func on_new_pressed():
	hide_game_menu()
	game.new_game()
	pause_popup.is_game_active = true

func on_play_pressed():
	if game.active:
		hide_game_menu()
	else:
		game.new_game()
		pause_popup.is_game_active = true
		hide_game_menu()

func on_quit_pressed():
	get_tree().quit()

func show_game_menu():
	pause_popup.show()
	pause_popup.set_position(get_viewport().size * 0.5 - pause_popup.rect_size * 0.5)
	get_tree().paused = true

func hide_game_menu():
	pause_popup.hide()
	get_tree().paused = false

func toggle_game_menu():
	if pause_popup.visible:
		hide_game_menu()
	else:
		show_game_menu()

func _process(delta):
	elapsed_time += delta
	
	var i = 0
	while i < scheduled_calls.size():
		var call = scheduled_calls[i]
		if elapsed_time >= call.time:
			scheduled_calls.remove(i)
			call.obj.callv(call.method_name, call.args)
		else:
			i += 1

func schedule_call(delay_seconds, obj, method_name, args = []):
	var call = {
		"time":        elapsed_time + delay_seconds,
		"obj":         obj,
		"method_name": method_name,
		"args":        args
	}
	scheduled_calls.push_back(call)

func on_game_over():
	pause_popup.is_game_active = false
	show_game_menu()

func _input(event):
	if event is InputEventKey:
		var key_event : InputEventKey = event
		if key_event.pressed && !key_event.echo:
			if key_event.scancode == KEY_ESCAPE:
				print("main detected escape")
				toggle_game_menu()