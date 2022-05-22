extends Area2D

var velocity : Vector2
var lifespan : float

func _ready():
	pass

func _process(delta):
	lifespan -= delta
	if lifespan < 0:
		self.queue_free()

func _physics_process(delta):
	position += velocity * delta
	
	var border = 7
	if position.x < -border:
		position.x += get_viewport().size.x + border * 2
	if position.x > get_viewport().size.x + border:
		position.x -= get_viewport().size.x + border * 2
		
	if position.y < -border:
		position.y += get_viewport().size.y + border * 2
	if position.y > get_viewport().size.y + border:
		position.y -= get_viewport().size.y + border * 2

func _on_area_shape_entered(area_rid, area : Area2D, area_shape_index, local_shape_index):
	if area.collision_layer == 1 << 0:
		print("This bullet has struck the player ... somehow.")
	elif area.collision_layer == 1 << 1:
		self.queue_free()
	elif area.collision_layer == 1 << 2:
		print("This bullet has struck another bullet ... somehow.")
