class_name HUD
extends CanvasLayer

@onready var dung: Label = %Dung
@onready var inventory_container: HBoxContainer = %InventoryContainer
@onready var health_bar: ProgressBar = $HealthBar
@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var timer_label: Label = $Timer/TimerLabel


func _ready() -> void:
	var current_player_data: Statics.PlayerData = Game.get_current_player()
	var inv = current_player_data.inventory_hud
	
	dung.text = str(current_player_data.dung)
	current_player_data.dung_changed.connect(_on_dung_changed)
	
	_on_inventory_changed(current_player_data.inventory_hud)
	current_player_data.inventory_changed.connect(_on_inventory_changed)
func set_timer_label(text: String) -> void:
	timer_label.text = text

func _on_dung_changed(value:int) -> void:
	dung.text = str(value)

func _on_inventory_changed(value: Dictionary) -> void:
	for child in inventory_container.get_children():
		child.queue_free()

	for category in ["weapon", "armor", "perks"]:
		if !value.has(category):
			continue

		for item in value[category]:
			var icon := TextureRect.new()
			icon.texture = item.image
			icon.custom_minimum_size = Vector2(16, 16)
			icon.size = Vector2(16, 16)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			inventory_container.add_child(icon)
