class_name  ItemCard
extends PanelContainer

@onready var display_name: Label = %DisplayName
@onready var image: TextureRect = %Image
@onready var description: RichTextLabel = %Description
@onready var price: Label = %Price


@export var item_data: ItemData:
	set(value):
		item_data = value
		update()
		

func update() -> void:
	if not is_node_ready():
		return
	display_name.text = item_data.display_name
	image.texture = item_data.image
	description.text = item_data.description
	price.text = "Price: " + str(item_data.price) + " Dung"
