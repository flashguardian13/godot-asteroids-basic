extends Node2D

export(PackedScene) var asteroid_scene
export(PackedScene) var player_bullet_scene
export(PackedScene) var player_scene

export(AudioStream) var blaster_fire

class AudioStreamPool:
	var pool : Array
	
	func add(path):
		var res = ResourceLoader.load(path, "AudioStream")
		pool.push_back(res)

	func sample():
		return pool[randi() % pool.size()]

var asteroid_hit_sound_pool : AudioStreamPool
var asteroid_break_sound_pool : AudioStreamPool

var ships_remaining = 3
var score = 0
var level = 1
var active = false

var main : Node2D
var player_ship : Area2D

signal score_changed
signal ship_count_changed
signal level_changed
signal game_over

func _ready():
	randomize()
	
	asteroid_hit_sound_pool = AudioStreamPool.new()
	var i = 1
	while i <= 9:
		asteroid_hit_sound_pool.add("res://sound/asteroid_hits/AsteroidHit0%s.tres" % i)
		i += 1
	
	asteroid_break_sound_pool = AudioStreamPool.new()
	i = 1
	while i <= 4:
		asteroid_break_sound_pool.add("res://sound/asteroid_breaks/AsteroidBreak0%s.tres" % i)
		i += 1
	

func clear():
	for child in get_children():
		if child != $Overlay && child != player_ship:
			remove_child(child)
			child.queue_free()

func new_game():
	ships_remaining = 3
	emit_signal("ship_count_changed", ships_remaining)
	score = 0
	emit_signal("score_changed", score)
	level = 1
	emit_signal("level_changed", level)
	active = true
	
	populate()

	var announcer = get_node("Overlay/AnnouncerLabel")
	announcer.show_message("3 ...", 1)
	announcer.show_message("2 ...", 1)
	announcer.show_message("1 ...", 1)
	announcer.show_message("Go!", 1)
	main.schedule_call(3, self, "spawn_player")

func spawn_player():
	player_ship = player_scene.instance()
	player_ship.position.x = get_viewport().size.x * 0.5
	player_ship.position.y = get_viewport().size.y * 0.5
	player_ship.rotation = 0
	player_ship.velocity.x = 0
	player_ship.velocity.y = 0
	player_ship.visible = true
	player_ship.make_incorporeal()
	player_ship.connect("destroyed", self, "_on_player_destroyed")
	add_child(player_ship)

func populate():
	clear()
			
	var difficulty = 5 + level
	while difficulty > 0:
		var asteroid_size = 3
		if difficulty < 3:
			asteroid_size = difficulty
		spawn_asteroid(asteroid_size)
		difficulty -= asteroid_size

func _process(delta):
	var asteroids = get_tree().get_nodes_in_group("asteroids")
	if asteroids.size() <= 0:
		level += 1
		emit_signal("level_changed", level)
		populate()
		get_node("Overlay/AnnouncerLabel").show_message(("Level %s" % level), 3)

func spawn_asteroid(size_category, position = null, velocity = null):
	var asteroid : Area2D = asteroid_scene.instance()
	asteroid.add_to_group("asteroids")
	
	if position == null:
		var spawn_x = rand_range(0, get_viewport().size.x)
		var spawn_y = rand_range(0, get_viewport().size.y)
		var side = randi() % 4
		if side == 0:
			spawn_x = 0 - asteroid.border
		if side == 1:
			spawn_x = get_viewport().size.x + asteroid.border
		if side == 2:
			spawn_y = 0 - asteroid.border
		if side == 3:
			spawn_y = get_viewport().size.y + asteroid.border
		asteroid.position = Vector2(spawn_x, spawn_y)
	else:
		asteroid.position = position
	
	if velocity == null:
		asteroid.velocity = Vector2(rand_range(50.0, 100.0), 0.0).rotated(rand_range(0, 2 * PI))
	else:
		asteroid.velocity = velocity
	
	asteroid.rotation = rand_range(0, 2 * PI)
	
	asteroid.size_category = size_category
	if size_category == 1:
		asteroid.scale = Vector2(0.33, 0.33)
		asteroid.health = 1
	elif size_category == 2:
		asteroid.scale = Vector2(0.67, 0.67)
		asteroid.health = 3
	elif size_category == 3:
		asteroid.health = 9
		
	asteroid.connect("damaged", self, "hit_asteroid")
	asteroid.connect("destroyed", self, "split_asteroid")
	
	add_child(asteroid)
	
	return asteroid

func hit_asteroid(_asteroid, impact_position):
	play_sound_at_position(asteroid_hit_sound_pool.sample(), impact_position)
	
func split_asteroid(asteroid, impact_position):
	score += 100
	emit_signal("score_changed", score)
	
	play_sound_at_position(asteroid_break_sound_pool.sample(), impact_position)
	
	if asteroid.size_category <= 1:
		return
	
	var i = 0
	var new_size = asteroid.size_category - 1
	var asteroids = []
	while i < 3:
		var dir = Vector2(1, 0).rotated(2 * PI * i / 3)
		var new_asteroid = spawn_asteroid(
			new_size,
			asteroid.position + dir * 20 * new_size,
			asteroid.velocity + dir * 50
		)
		new_asteroid.rotation = rand_range(0, 2 * PI)
		asteroids.push_back(new_asteroid)
		i += 1
	
	for asteroid in asteroids:
		for other_asteroid in asteroids:
			if asteroid != other_asteroid:
				asteroid.siblings.push_back(other_asteroid)

func spawn_player_bullet():
	if player_ship == null:
		return
	
	var bullet = player_bullet_scene.instance()
	bullet.position = player_ship.position
	bullet.rotation = player_ship.rotation
	bullet.velocity = Vector2(600.0, 0.0).rotated(player_ship.rotation - PI * 0.5)
	bullet.lifespan = 0.5
	add_child(bullet)
	play_sound_at_position(blaster_fire, player_ship.position)

func play_sound_at_position(stream : AudioStream, position : Vector2):
	var sound:AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	sound.stream = stream
	sound.position = position
	add_child(sound)
	sound.connect("finished", sound, "queue_free")
	sound.play()

func _input(ev):
	if ev is InputEventKey:
		var key_event : InputEventKey = ev
		if key_event.scancode == KEY_SPACE && key_event.pressed && !key_event.echo:
			spawn_player_bullet()

func _on_player_destroyed(_player):
	if ships_remaining > 0:
		ships_remaining -= 1
		emit_signal("ship_count_changed", ships_remaining)
		if ships_remaining <= 0:
			player_ship.visible = false
			active = false
			emit_signal("game_over")
			get_node("Overlay/AnnouncerLabel").show_message("Game over", 3)
