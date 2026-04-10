extends Control

@onready var shop_buttons: Control = $MarginContainer/VBoxContainer/MarginContainer/Panel/ShopButtons
@onready var shop_buttons_2: Control = $MarginContainer/VBoxContainer/MarginContainer/Panel/ShopButtons2
@onready var shop_buttons_3: Control = $MarginContainer/VBoxContainer/MarginContainer/Panel/ShopButtons3

var items = [
	{
		"name": "Dragonfly perk",
		"cost": 10,
		"texture": "res://assets/shop assets/sprite 1.png",
		"tooltip": "+ 10% velocity"
	},
	{
		"name": "Crossbow",
		"cost": 12,
		"texture": "res://assets/shop assets/Crossbow.png",
		"tooltip": "20 damage"
	},
	{
		"name": "Bee perk",
		"cost": 12,
		"texture": "res://assets/shop assets/Sprite 3.png",
		"tooltip": "+ 10% damage"
	},
	{
		"name": "Spear",
		"cost": 5,
		"texture": "res://assets/shop assets/53.png",
		"tooltip": "10 damage"
	},
	{
		"name": "Ladybug perk",
		"cost": 8,
		"texture": "res://assets/shop assets/Sprite 2.png",
		"tooltip": "+ 10% life"
	}
]

func _ready():
	randomize()
	
	# Mezclar ítems y tomar 3 aleatorios
	var selected_items = items.duplicate()
	selected_items.shuffle()
	selected_items.shuffle()
	selected_items = selected_items.slice(0, 3)
	
	# Lista de contenedores de botones
	var shops = [shop_buttons, shop_buttons_2, shop_buttons_3]
	
	# Asignar datos a cada botón
	for i in range(shops.size()):
		var button = shops[i].get_node("Button")
		var texture_rect = button.get_node("MarginContainer/TextureRect")
		var label = button.get_node("Label")
		var label2 = button.get_node("Label2")
		
		var item = selected_items[i]
		
		texture_rect.texture = load(item["texture"])
		label.text = item["name"]
		label2.text = "Cost: %d dung" % item["cost"]
		button.tooltip_text = item["tooltip"]
