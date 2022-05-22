extends Area2D

signal destroyed

var velocity : Vector2
var size_category : int
var siblings = []
var border = 70

func _ready():
	pass

func _process(delta):
	pass

func _physics_process(delta):
	position += velocity * delta
	
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
		print("This asteroid has struck the player.")
	elif area.collision_layer == 1 << 1:
		if !siblings.has(area):
			velocity = velocity.bounce((self.position - area.position).normalized())
	elif area.collision_layer == 1 << 2:
		emit_signal("destroyed", self)
		self.queue_free()

func _on_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	if area == null:
		return
	
	if area.collision_layer == 1 << 1:
		siblings.erase(area)
