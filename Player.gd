extends Area2D

export (int) var thrust = 5
export (float) var linear_velocity_max = 500
export (float) var rotation_speed = 3
export (float) var linear_damping = 0.1
export (float) var border_width = 20

var velocity = Vector2()

signal destroyed

func _ready():
	pass

func make_incorporeal():
	$Sprite.modulate = Color(1,1,1,0.5)
	monitoring = false
	monitorable = false
	$SpawnTimer.start(3)

func make_corporeal():
	$Sprite.modulate = Color(1,1,1,1)
	monitoring = true
	monitorable = true

func get_inputs():
	var thrust_dir = 0
	var rotation_dir = 0
	
	if Input.is_action_pressed("ui_right"):
		rotation_dir += 1
	if Input.is_action_pressed("ui_left"):
		rotation_dir -= 1
	
	if Input.is_action_pressed("ui_down"):
		thrust_dir += 1
	if Input.is_action_pressed("ui_up"):
		thrust_dir -= 1
	
	return { "thrust": thrust_dir, "rotation": rotation_dir }

func _physics_process(delta):
	var inputs = get_inputs()
	
	rotation += inputs["rotation"] * rotation_speed * delta
	
	if inputs["thrust"] != 0:
		velocity += Vector2(0, inputs["thrust"] * thrust).rotated(rotation)
		if !$ThrusterLoopPlayer2D.playing:
			$ThrusterLoopPlayer2D.play()
	else:
		if $ThrusterLoopPlayer2D.playing:
			$ThrusterLoopPlayer2D.stop()
	velocity -= velocity * linear_damping * delta
	velocity = velocity.clamped(linear_velocity_max)
	
	position += velocity * delta
	
	if position.x < -border_width:
		position.x = position.x + get_viewport_rect().size.x + border_width * 2
	if position.x > get_viewport_rect().size.x + border_width:
		position.x = position.x - get_viewport_rect().size.x - border_width * 2
	if position.y < -border_width:
		position.y = position.y + get_viewport_rect().size.y + border_width * 2
	if position.y > get_viewport_rect().size.y + border_width:
		position.y = position.y - get_viewport_rect().size.y - border_width * 2

func _process(delta):
	pass

func _on_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.collision_layer == 1 << 0:
		print("Player hit ... xemself?????")
	elif area.collision_layer == 1 << 1:
		position.x = rand_range(0, get_viewport_rect().size.x)
		position.y = rand_range(0, get_viewport_rect().size.y)
		emit_signal("destroyed", self)
	elif area.collision_layer == 1 << 2:
		print("Player hit ... their own bullet, this should not be possible.")
