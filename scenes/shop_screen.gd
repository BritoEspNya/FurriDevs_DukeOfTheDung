extends Control

@onready var shop_buttons: Control = $MarginContainer/VBoxContainer/MarginContainer/Panel/ShopButtons
@onready var shop_buttons_2: Control = $MarginContainer/VBoxContainer/MarginContainer/Panel/ShopButtons2
@onready var shop_buttons_3: Control = $MarginContainer/VBoxContainer/MarginContainer/Panel/ShopButtons3

@onready var sprite = "res://assets/shop assets/sprite 1.png"

func _ready():
	var button = shop_buttons.get_node("Button")
	var texture_rect = button.get_node("MarginContainer/TextureRect")
	var label = button.get_node("Label")
	var label2 = button.get_node("Label2")

	texture_rect.texture = preload("res://assets/shop assets/sprite 1.png")
	label.text = "Dragonfly perk"
	label2.text = "Cost: 10 dung"
	button.tooltip_text = "+ 10% velocity"
	
