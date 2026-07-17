class_name Ball
extends RigidBody2D

var _near_players: Array[Node2D]
var attached_player: Player
var is_attached: bool = false
var is_charging: bool = false

var distance: float = 150
@export var follow_weight: float = 0.2
@export var max_speed: float = 200

@onready var area_2d: Area2D = $Area2D
@onready var barrier: Area2D = $Barrier
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var charge_bar: ProgressBar = $TextureRect/ChargeBar
@onready var texture_rect: TextureRect = $TextureRect

var last_position: Vector2 = Vector2.ZERO
var current_offset: Vector2 = Vector2.ZERO

var charge: int = 0
var max_charge: int = 4
var charge_per_tick: int = 1
var charge_timer: float = 0.0
var charge_recover_interval: float = 0.8
var last_charge: int = 0
var was_attached: bool = false

func _ready() -> void:
		area_2d.body_entered.connect(_on_body_entered)
		area_2d.body_exited.connect(_on_body_exit)
		barrier.area_entered.connect(_on_area_entered)
		texture_rect.hide()
		last_position = global_position
		
func _physics_process(delta: float) -> void:
	if is_attached:
		var target_pos = attached_player.ball_point.global_position
		var displacement = target_pos - global_position
		var calc_velocity: Vector2 = (displacement * follow_weight)/delta
		linear_velocity = calc_velocity.limit_length(max_speed)
		
		if is_charging:
			if charge < max_charge:
				charge_timer += delta
				if charge_timer >= charge_recover_interval:
					charge_timer = 0.0
					charge += charge_per_tick
					charge = min(charge, max_charge)
					charge_bar.value = charge
	else:
		if was_attached:
			if last_charge > 0:
				linear_velocity = linear_velocity * last_charge
				last_charge = 0
				was_attached = false
			else:
				linear_velocity = linear_velocity.limit_length(max_speed*2)

	var displacement = global_position - last_position
	
	if displacement != Vector2.ZERO:
		# Factor in the sprite's global scale so the texture rolls 
		# relative to its visible size, not its giant 2048x2048 texture size
		var visible_width = sprite_2d.texture.get_width() * sprite_2d.global_scale.x
		var visible_height = sprite_2d.texture.get_height() * sprite_2d.global_scale.y
		
		current_offset.x -= displacement.x / visible_width
		current_offset.y -= displacement.y / visible_height
		
		sprite_2d.set_instance_shader_parameter("texture_offset", current_offset)
		
	last_position = global_position
	
func _input(event: InputEvent) -> void:
	var player: Player = Game.get_current_player().scene
	# Attach & Detach
	if event.is_action_pressed("input_movement_mode"):
		if _near_players.has(player):
			if player == attached_player:
				if !is_attached:
					attach.rpc(player.get_path())
				else:
					detach.rpc(player.get_path())
	# Ball Rush
	if is_attached:
		if event.is_action_pressed("input_space"):
			texture_rect.show()
			is_charging = true
		
		if event.is_action_released("input_space"):
			player.input_synchronizer.mode_input = false
			detach.rpc(player.get_path())
			last_charge = charge
			charge = 0
			charge_bar.value = charge
			texture_rect.hide()
			is_charging = false
					
@rpc("any_peer", "call_local", "reliable")
func attach(player_path: NodePath) -> void:
	#freeze = true
	var player: Player = get_node(player_path)
	if !attached_player:
		attached_player = player
	if attached_player == player:
		set_collision_mask_value(1, false)
		set_collision_layer_value(1, false)
		is_attached = true
		player.input_synchronizer.mode_input = false
		was_attached = true
		print("Layer:", collision_layer)
		print("Mask:", collision_mask)

@rpc("any_peer", "call_local", "reliable")
func detach(player_path: NodePath) -> void:
	#freeze = false
	var player: Player = get_node(player_path)
	set_collision_mask_value(1, true)
	set_collision_layer_value(1, true)
	is_attached = false
	player.input_synchronizer.mode_input = true

func _on_body_entered(body: Node2D) -> void:
	var player = body as Player
	if player:
		_near_players.push_back(player)

func _on_area_entered(area: Area2D) -> void:
	var projectile: Projectile = area as Projectile
	#Debug.log("xao1")
	if projectile:
		Debug.log("xao2")
		if is_multiplayer_authority():
			#await get_tree().create_timer(0.05).timeout
			projectile.queue_free()

func _on_body_exit(body: Node2D) -> void:
	_near_players.erase(body)
