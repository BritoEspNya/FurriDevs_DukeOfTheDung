class_name HUD
extends CanvasLayer

@onready var dung: Label = %Dung
@onready var inventory_container: HBoxContainer = %InventoryContainer
@onready var health_bar: ProgressBar = %HealthBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var timer_label: Label = $Timer/TimerLabel
@onready var weapon_icon: Sprite2D = %WeaponIcon
@onready var life_hud: Node2D = $LifeHUD
@onready var weapon_hud: Control = $WeaponHUD
@onready var shop_dung: Node2D = $ShopDung
@onready var dung_cnt_shop: Label = $ShopDung/PanelContainer/Dung



func _ready() -> void:
	var player := get_parent() as Player
	var current_player_data: Statics.PlayerData = Game.get_current_player()
	var inv = current_player_data.inventory_hud
	shop_ui(false)
	dung.text = str(current_player_data.dung)
	dung_cnt_shop.text = str(current_player_data.dung)
	current_player_data.dung_changed.connect(_on_dung_changed)
	player.weapon_equipped.connect(_on_weapon_equipped)
	_on_inventory_changed(current_player_data.inventory_hud)
	current_player_data.inventory_changed.connect(_on_inventory_changed)
	# Inicializa el selector con el arma que ya esté equipada.
	if is_instance_valid(player.current_weapon):
		_on_weapon_equipped(
			player.current_weapon_idx,
			player.current_weapon.get_hud_icon()
		)
func set_timer_label(text: String) -> void:
	timer_label.text = text

func _on_weapon_equipped(
	_weapon_idx: int,
	weapon_texture: Texture2D
) -> void:
	if weapon_texture == null:
		Debug.log("HUD received a null weapon texture")
		return
	var deb: String = "New texture is: " + str(weapon_texture)
	Debug.log(deb)
	weapon_icon.texture = weapon_texture

func _on_dung_changed(value:int) -> void:
	dung.text = str(value)
	dung_cnt_shop.text = str(value)
	

func _on_inventory_changed(value: Dictionary) -> void:
	for child in inventory_container.get_children():
		child.queue_free()

	for category in ["weapon", "armor", "perks"]:
		if !value.has(category):
			continue

		for item in value[category]:
			var icon := TextureRect.new()
			icon.texture = item.image
			icon.custom_minimum_size = Vector2(30, 30)
			icon.size = Vector2(30, 30)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			inventory_container.add_child(icon)
			
			
func shop_ui(enable: bool) -> void: 
	var deb: String = "LA UI CAMBIO CON enable = "+str(enable)
	Debug.log(deb)
	life_hud.visible = not enable
	weapon_hud.visible = not enable
	shop_dung.visible = enable
