extends Label

var message_queue = []

func _ready():
	pass

func _process(delta):
	if !visible && message_queue.size() > 0:
		var msg = message_queue.pop_front()
		show_message(msg["text"], msg["duration"])

func show_message(message, duration):
	if visible:
		message_queue.push_back({ "text": message, "duration": duration })
	else:
		set_text_and_reposition(message)
		$Timer.start(duration)

func set_text_and_reposition(msg : String):
	visible = true
	text = msg
	self.rect_position.x = get_viewport().size.x * 0.5 - self.rect_size.x * 0.5
	self.rect_position.y = get_viewport().size.y * 0.5 - self.rect_size.y * 0.5

func _on_timeout():
	if message_queue.size() > 0:
		var msg = message_queue.pop_front()
		set_text_and_reposition(msg["text"])
		$Timer.start(msg["duration"])
	else:
		visible = false
