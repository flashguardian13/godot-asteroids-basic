extends Area2D

export (int) var thrust = 25
export (float) var rotation_speed = 5
export (float) var border_width = 20

var velocity = Vector2()

func _ready():
	pass # Replace with function body.

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
	velocity -= velocity * 1 * delta
	
	position += velocity * delta
	
	if position.x < -border_width:
		position.x = position.x + get_viewport_rect().size.x + border_width * 2
	if position.x > get_viewport_rect().size.x + border_width:
		position.x = position.x - get_viewport_rect().size.x - border_width * 2
	if position.y < -border_width:
		position.y = position.y + get_viewport_rect().size.y + border_width * 2
	if position.y > get_viewport_rect().size.y + border_width:
		position.y = position.y - get_viewport_rect().size.y - border_width * 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
