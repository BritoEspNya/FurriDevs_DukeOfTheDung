extends Control

@export var item_card_scene: PackedScene
@export var item_data_array: Array[ItemData]
@onready var item_card_container: HBoxContainer = %ItemCardContainer
@onready var item_card_1: PanelContainer = %ItemCard1
@onready var item_card_2: PanelContainer = %ItemCard2
@onready var item_card_3: PanelContainer = %ItemCard3


func _ready() -> void:
	generate_cards()
	

func generate_cards() -> void:
	if not item_card_scene:
		return
	
	var available_items = item_data_array.duplicate()
	
	for margin_container in item_card_container.get_children():
		var item_card: ItemCard = margin_container.get_child(0)
		
		var random_item = available_items.pick_random()
		item_card.item_data = random_item
		
		available_items.erase(random_item)
