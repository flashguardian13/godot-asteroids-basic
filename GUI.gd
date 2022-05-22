extends MarginContainer

var ship_image = preload("res://images/ship_1.png")

var ship_icons_visible = []
var ship_icons_hidden = []
var ships_panel : HBoxContainer
var score_label : Label
var level_label : Label

func _ready():
	ships_panel = get_node("PanelContainer/HBoxContainer/ShipsPanel")
	score_label = get_node("PanelContainer/HBoxContainer/HBoxContainer/ScorePanel/Score")
	level_label = get_node("PanelContainer/HBoxContainer/HBoxContainer/LevelPanel/Level")
	display_ships(3)

func add_ship_icon():
	var icon:TextureRect = TextureRect.new()
	icon.texture = ship_image
	ships_panel.add_child(icon)
	ship_icons_visible.push_back(icon)

func show_ship_icon():
	var icon = ship_icons_hidden.pop_back()
	ships_panel.add_child(icon)
	ship_icons_visible.push_back(icon)

func hide_ship_icon():
	var icon = ship_icons_visible.pop_back()
	ships_panel.remove_child(icon)
	ship_icons_hidden.push_back(icon)

func display_ships(count):
	while ship_icons_visible.size() > count:
		hide_ship_icon()
	while ship_icons_visible.size() < count:
		if ship_icons_hidden.size() > 0:
			show_ship_icon()
		else:
			add_ship_icon()

func display_score(score):
	score_label.text = String(score)

func display_level(level):
	level_label.text = String(level)
