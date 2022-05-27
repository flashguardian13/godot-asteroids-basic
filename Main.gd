extends Node2D

export(AudioStream) var level_clear
export(AudioStream) var game_over

export(AudioStream) var menu_select

export(AudioStream) var title_song

class GameMusicSet:
	var pool : Array
	var index : int
	
	func add(path):
		var res = ResourceLoader.load(path, "AudioStream")
		pool.push_back(res)

	func shuffle():
		index = 0
		var randomized_set : Array = []
		while pool.size() > 0:
			var song = pool.pop_at(randi() % pool.size())
			randomized_set.push_back(song)
		pool = randomized_set
	
	func get_current_song():
		return pool[index]
		
	func get_next_song():
		index = (index + 1) % pool.size()
		return pool[index]

var game_music_set : GameMusicSet

var game : Node2D
var gui : MarginContainer
var pause_popup : PopupPanel

var scheduled_calls : Array
var elapsed_time : float

func _ready():
	game_music_set = GameMusicSet.new()
	game_music_set.add("res://sound/music/GameLoop_Clinthammer_ElectroBeat2.tres")
	game_music_set.add("res://sound/music/GameLoop_Clinthammer_ElectroBeat.tres")
	game_music_set.add("res://sound/music/GameLoop_Clinthammer_LightGlitchSteppa.tres")
	game_music_set.add("res://sound/music/GameLoop_Clinthammer_RobotNapPercussion.tres")
	game_music_set.add("res://sound/music/GameLoop_Clinthammer_TsBass.tres")
	game_music_set.add("res://sound/music/GameLoop_DayTripper13_RemixBeat3142011.tres")
	game_music_set.add("res://sound/music/GameLoop_Nomiqbomi_Transist2.tres")
	game_music_set.shuffle()
		
	play_song(title_song)
	
	game = get_node("VBoxContainer/ViewportContainer/Viewport/Game")
	game.main = self
	gui = get_node("VBoxContainer/GUI")
	pause_popup = get_node("PausePopupDialog")
	
	game.connect("score_changed", gui, "display_score")
	game.connect("ship_count_changed", gui, "display_ships")
	game.connect("level_changed", gui, "display_level")
	game.connect("level_up", self, "play_next_game_song")
	game.connect("game_over", self, "on_game_over")
	
	gui.display_score(game.score)
	gui.display_ships(game.ships_remaining)
	gui.display_level(game.level)
	
	var button = pause_popup.get_node("VBoxContainer/VBoxContainer/NewButton")
	button.connect("pressed", self, "on_new_pressed")
	button = pause_popup.get_node("VBoxContainer/VBoxContainer/ResumeButton")
	button.connect("pressed", self, "on_resume_pressed")
	button = pause_popup.get_node("VBoxContainer/VBoxContainer/QuitButton")
	button.connect("pressed", self, "on_quit_pressed")
	
	show_game_menu()

func on_new_pressed():
	$SoundPlayer.stream = menu_select
	$SoundPlayer.play()
	game_music_set.shuffle()
	hide_game_menu()
	game.new_game()
	pause_popup.is_game_active = true

func on_resume_pressed():
	$SoundPlayer.stream = menu_select
	$SoundPlayer.play()
	hide_game_menu()
	if !game.active:
		game.new_game()
		pause_popup.is_game_active = true

func on_quit_pressed():
	$SoundPlayer.stream = menu_select
	$SoundPlayer.play()
	get_tree().quit()

func show_game_menu():
	pause_popup.get_node("VBoxContainer/VBoxContainer/ResumeButton").visible = game.active
	pause_popup.set_position(get_viewport().size * 0.5 - pause_popup.rect_size * 0.5)
	pause_popup.call_deferred("show")
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
	game.active = false
	pause_popup.is_game_active = false
	show_game_menu()
	play_song(title_song)

func play_next_game_song():
	play_song(game_music_set.get_next_song())

func play_song(song):
	print("Now playing: %s" % song)
	$MusicPlayer.stream = song
	$MusicPlayer.play()

func play_stinger(music):
	if music == "game over":
		$StingPlayer.stream = game_over
		$StingPlayer.play()
	elif music == "level clear":
		$StingPlayer.stream = level_clear
		$StingPlayer.play()
	else:
		print("Unknown song: %s" % music)

func _input(event):
	if event is InputEventKey:
		var key_event : InputEventKey = event
		if key_event.pressed && !key_event.echo:
			if key_event.scancode == KEY_ESCAPE:
				print("main detected escape")
				toggle_game_menu()
