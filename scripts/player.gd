class_name Player
extends CharacterBody2D

signal respawned
signal died
signal weapon_equipped(weapon_index: int, weapon_icon: Texture2D)

@export var walk_speed: float = 400
@export var flight_speed: float = 1000
@export var carry_speed: float = 200
@export var acceleration: float = 400
@export var rotation_speed: float = 5
#@export var projectile_scene: PackedScene
@export var current_weapon_idx: int = 0
@export var weapon_scenes: Array[PackedScene] # por defecto: Array[melee_weapon.scene()] 

var _data: Statics.PlayerData
var _speed: float = walk_speed
var current_weapon: Weapon
var is_flying: bool
@export var current_level: int = 0
var weapon_damage_multiplier: float = 1.0
@export var max_stamina: int = 10
@export var stamina: int = 10:
	set(value):
		var new_stamina = clamp(value, 0, max_stamina)
		if stamina == new_stamina:
			return
		stamina = new_stamina
		#stamina_changed.emit(stamina, max_stamina)
var stamina_decrease_interval := 0.5  # cada 0.5s se descuenta 1
var stamina_recover_interval := 0.8  # cada 0.8s se recupera 1
var stamina_recover_delay := 1.0     # espera 1s tras dejar de correr
var stamina_per_tick := 1
var stamina_timer := 0.0
var recovering_stamina := false
var stamina_recover_timer := 0.0
var stamina_locked := false  # impide correr si no hay stamina suficiente

var target_max_speed: float = walk_speed
var current_max_speed: float = walk_speed
var deceleration_rate: float = 5.0

@onready var label: Label = $Pivot/Label
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var camera_2d: Camera2D = $Camera2D
@onready var input_synchronizer: InputSyncronizer = $InputSynchronizer
@onready var sync_timer: Timer = $SyncTimer
@onready var dung_recolected: int = 0
#@onready var projectile_spawner: MultiplayerSpawner = $ProjectileSpawner
#@onready var projectile_spawn_marker: Marker2D = $Pivot/ProjectileSpawnMarker
@onready var health_component: HealthComponent = $HealthComponent
@onready var hud: HUD = $HUD
@onready var health_bar: ProgressBar = $HealthBar
#@onready var hud: CanvasLayer = $HUD
@onready var respawn_timer: Timer = $RespawnTimer


@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent

@onready var pivot: Node2D = $Pivot
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var ball_pivot: Node2D = $BallPivot
@onready var ball_point: Marker2D = $BallPivot/BallPoint
#@onready var spear: Spear = $WeaponPivot/Weapons/Spear
@onready var weapon_spawn_point: Marker2D = $WeaponPivot/WeaponSpawnPoint
@onready var weapon_spawner: MultiplayerSpawner = $WeaponSpawner
@onready var attack_spawner: MultiplayerSpawner = $AttackSpawner


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	health_component.revived.connect(_on_revived)
	sync_timer.timeout.connect(_on_sync_timeout)
	weapon_spawner.spawned.connect(_on_weapon_spawned)
	setup_weapon_spawner(weapon_scenes)
	#if projectile_scene: # Para proyectiles propios del player
		#projectile_spawner.add_spawnable_scene(projectile_scene.resource_path)
 	
	hud.health_bar.max_value = health_component.max_health
	hud.health_bar.value = health_component.health
	hud.stamina_bar.max_value = max_stamina
	hud.stamina_bar.value = stamina
	health_bar.max_value = health_component.max_health
	respawn_timer.timeout.connect(_on_respawn_timeout)
	health_bar.value = health_component.health
	#
	
	
	
func _physics_process(delta: float) -> void:
	var move_input: Vector2 = input_synchronizer.move_input
	is_flying = input_synchronizer.flight_input 
	if input_synchronizer.mode_input:			
		# Flight mode
		if is_flying and stamina > 0:
			_speed = flight_speed
			target_max_speed = flight_speed
			if move_input:
				stamina_timer += delta
				stamina_recover_timer = 0.0

				if stamina_timer >= stamina_decrease_interval:
					stamina_timer = 0.0
					stamina = max(stamina - stamina_per_tick, 0)
					hud.stamina_bar.value = stamina
		else:
			_speed = walk_speed
			target_max_speed = walk_speed
			
		current_max_speed = lerp(current_max_speed, target_max_speed, deceleration_rate * delta)
		# Normal Movement
		velocity.x = move_toward(velocity.x, move_input.x * _speed, acceleration * delta)
		velocity.y = move_toward(velocity.y, move_input.y * _speed, acceleration * delta)
		if velocity.length() > 0:
			var angle: float = velocity.angle() + PI / 2
			pivot.rotation = lerp_angle(pivot.rotation, angle, rotation_speed * delta)
		# Weapon movement and fire
		if is_multiplayer_authority():
			var aim_direction := global_position.direction_to(get_global_mouse_position())
			weapon_pivot.rotation = aim_direction.angle()
			if current_weapon:
				current_weapon.set_sprite_flipped(aim_direction.x < 0.0)
			if input_synchronizer.attack_input and not input_synchronizer.flight_input:
				#fire()
				#if not weapon_scenes:
					#pass
				if current_weapon:
					current_weapon.main_attack()
			if Input.is_action_just_pressed("dev_level_up"):
				var deb: String = "current buyer_id: " + str(get_id())
				Debug.log(deb)
				var level_item: ItemData = preload("uid://cwal2h6c7y8ww")
				Game.request_buy_item.rpc(level_item.resource_path)
				#self.equip_weapon_inv(spear_item)
			if Input.is_action_just_pressed("dev_swap_weapon"):
				swap_weapon.rpc()
			if Input.is_action_just_pressed("debug_buy_spear"):
					var deb: String = "current buyer_id: " + str(get_id())
					Debug.log(deb)
					var spear_item: ItemData = preload("uid://cb3cw5riphjx7")
					Game.request_buy_item.rpc(spear_item.resource_path)
					#self.equip_weapon_inv(spear_item)
			if Input.is_action_just_pressed("debug_free_dung"):
					if multiplayer.is_server():
						request_debug_add_dung(50)
					else:
						request_debug_add_dung.rpc_id(1, 50)
			
	else:
		pivot.rotation += move_input.x * rotation_speed * delta
		var forward_direction: Vector2 = Vector2.UP.rotated(pivot.rotation)
		velocity = velocity.move_toward(forward_direction * carry_speed * move_input.y, acceleration * delta)
	velocity = velocity.limit_length(current_max_speed)
	ball_pivot.rotation = pivot.rotation
	move_and_slide()
	
	# Stamina recovery
	if stamina < max_stamina:
		stamina_timer += delta
		if stamina_timer >= stamina_recover_interval:
			stamina_timer = 0.0
			stamina += stamina_per_tick
			stamina = min(stamina, max_stamina)
			hud.stamina_bar.value = stamina
	
	if input_synchronizer.move_input:
		if input_synchronizer.flight_input and stamina > 0:
			if input_synchronizer.mode_input:
				playback.travel("fly")
		else:
			playback.travel("walk")
	else:
		if get_real_velocity().is_zero_approx():
			playback.travel("idle")

func setup(data: Statics.PlayerData) -> void:
	_data = data
	name = str(data.id)
	label.text = data.name
	set_multiplayer_authority(data.id, false)
	multiplayer_synchronizer.set_multiplayer_authority(data.id, false)
	input_synchronizer.set_multiplayer_authority(data.id, false)
	#weapon_spawner.set_multiplayer_authority(1, false)
	camera_2d.enabled = is_multiplayer_authority()
	hud.visible = is_multiplayer_authority()
	health_bar.visible = not is_multiplayer_authority()
	#pivot.set_multiplayer_authority(data.id, false)
	if is_multiplayer_authority():
		sync_timer.start()
	if multiplayer.is_server():
		equip_weapon_ph(current_weapon_idx)
		#current_weapon.set_sprite_flipped(false)
		#current_weapon = weapon_scenes[current_weapon_idx].instantiate()
		#current_weapon.position = weapon_spawn_point.position
		#current_weapon.rotation = weapon_spawn_point.rotation
		#weapon_spawn_point.add_child(current_weapon, true)
		
func setup_weapon_spawner(weapon_scenes_array: Array[PackedScene]) -> void:
	for weapon_scene: PackedScene in weapon_scenes_array:
		if not weapon_scene:
			continue
		Debug.log("Weapon scene path: " + weapon_scene.resource_path)
		weapon_spawner.add_spawnable_scene(weapon_scene.resource_path)
		
func register_weapon_scene(weapon_scene: PackedScene) -> int:
	if weapon_scene == null:
		return -1
	var scene_path: String = weapon_scene.resource_path
	if scene_path.is_empty():
		push_error("La escena del arma no tiene resource_path")
		return -1
	
	# Verificamos que no exista el arma
	for index: int in weapon_scenes.size():
		var registered_scene: PackedScene = weapon_scenes[index]
		if registered_scene == null:
			continue
		if registered_scene.resource_path == scene_path:
			return index
	# Agregamos la escena del arma al spawner
	weapon_scenes.append(weapon_scene)
	weapon_spawner.add_spawnable_scene(scene_path)
	Debug.log(
		"Registered weapon scene: %s at index %d"
		% [scene_path, weapon_scenes.size() - 1]
	)
	return weapon_scenes.size() - 1

@rpc("authority", "call_local", "reliable")
func swap_weapon() -> void:
	var n: int = weapon_scenes.size()
	if n > 1:
		current_weapon_idx = (current_weapon_idx+1) % n
		Debug.log("SWAAAAP TO: " + str(current_weapon_idx))
		equip_weapon_ph(current_weapon_idx)

func equip_weapon_ph(weapon_idx: int) -> void:
	if not multiplayer.is_server():
		return

	if weapon_idx < 0 or weapon_idx >= weapon_scenes.size():
		var deb: String = "Invalid weapon index: " + str(weapon_idx)
		Debug.log(deb)
		return

	var weapon_scene: PackedScene = weapon_scenes[weapon_idx]
	if not weapon_scene:
		var deb: String = "Weapon scene is null at index: " + str(weapon_idx)
		Debug.log(deb)
		return

	if current_weapon and is_instance_valid(current_weapon):
		current_weapon.queue_free()

	current_weapon_idx = weapon_idx
	current_weapon = weapon_scene.instantiate() as Weapon

	current_weapon.position = Vector2.ZERO
	current_weapon.rotation = 0.0
	#current_weapon.name = "CurrentWeapon"
	
	#current_weapon.position = weapon_spawn_point.position
	#current_weapon.rotation = weapon_spawn_point.rotation
	weapon_spawn_point.add_child(current_weapon, true)
	current_weapon.set_damage_multiplier(weapon_damage_multiplier)
	Debug.log("SEÑAL EMITIDA DE CAMBIO DE ARMA, IDX= "+str(current_weapon_idx))
	sync_weapon_hud.rpc()
	
@rpc("any_peer", "call_local", "reliable")
func sync_weapon_hud() -> void:
	var icon: Texture2D = current_weapon.get_hud_icon()
	weapon_equipped.emit(current_weapon_idx, icon)

@rpc("authority", "call_remote", "unreliable_ordered")
func send_position(pos: Vector2) -> void:
	global_position = lerp(global_position, pos, 0.5)
	
func _on_weapon_spawned(node: Node) -> void:
	Debug.log("Weapon spawned locally: " + node.name)
	if node is Weapon:
		current_weapon = node

func _on_sync_timeout() -> void:
	if is_multiplayer_authority(): # HOTFIX
		send_position.rpc(global_position)
		
func _on_health_changed(value: int, max_value: int) -> void:
	var deb: String = str("HP: ", value, "/", max_value)
	Debug.log(deb)
	hud.health_bar.value = value
	health_bar.value = value
	# UI local, barra de vida, efectos visuales simples.

func _on_died() -> void:
	var deb: String = str("Player died visually: ", name)
	Debug.log(deb)
	_apply_dead_state(true)
	died.emit()

	if multiplayer.is_server():
		#_handle_server_death_logic()
		respawn_timer.start()
		
func _on_revived() -> void:
	respawned.emit() #Hotfix: El player se mueve a sí mismo?
	await get_tree().create_timer(0.5).timeout
	_apply_dead_state(false)
	
func _apply_dead_state(dead: bool) -> void:
	#visible = not dead
	set_physics_process(not dead)
	
	if is_multiplayer_authority():
		if dead:
			sync_timer.stop()
		elif sync_timer.is_stopped():
			sync_timer.start()

	if hurtbox_component:
		hurtbox_component.is_enabled = not dead
	if collision_shape_2d:
		collision_shape_2d.set_deferred("disabled", dead)
	if weapon_pivot:
		weapon_pivot.visible = not dead
	pivot.visible = not dead
	
	health_bar.visible = not dead and not is_multiplayer_authority()
	hud.visible = is_multiplayer_authority()
	velocity = Vector2.ZERO

func apply_respawn_position(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO

func get_id() -> int:
	return _data.id

func get_dung() -> int:
	return _data.dung
	
func set_timer_label(ltext: String) -> void:
	hud.set_timer_label(ltext)

func enter_shop(enable: bool) -> void:
	hud.shop_ui(not enable)

func increase_max_healt(value:int) -> void:
	var max_healt_increase: int = int(health_component.max_health*0.10)
	health_component.max_health += max_healt_increase
	health_component.health += max_healt_increase
	hud.health_bar.max_value = health_component.max_health
	hud.health_bar.value = health_component.health
	health_bar.max_value = health_component.max_health
	health_bar.value = health_component.health

func increase_velocity(value:int) -> void:
	walk_speed = walk_speed*value

func _on_respawn_timeout() -> void:
	#if is_multiplayer_authority():
		#Debug.log("RESPAWWWW")
		#respawned.emit()
	#await get_tree().create_timer(0.5).timeout
	health_component.revive_full()
	
func increase_dash(value:int) -> void:
	flight_speed += value
	Debug.log(flight_speed)
	
func increase_armor(value:int) -> void:
	health_component.armor = value
# Modifica el daño de todas las armas
func level_up() -> void:
	current_level += 1
	Debug.log("LEVEL UP TO: "+str(current_level))
	weapon_damage_multiplier = 1.0 + float(current_level) / 5.0
	_apply_damage_multiplier_to_current_weapon()
func _apply_damage_multiplier_to_current_weapon() -> void:
	if not is_instance_valid(current_weapon):
		return
	current_weapon.set_damage_multiplier(weapon_damage_multiplier)

func equip_weapon_inv(item) -> void:
	Debug.log("equipando arma")
	_data.inventory_hud["weapon"].append(item)
	_data.inventory_changed.emit(_data.inventory_hud)
	register_weapon_scene(item.weapon_scene)
	# Una vez 

func equip_armor(item) -> void:
	_data.inventory_hud["armor"] = [item]
	_data.inventory_changed.emit(_data.inventory_hud)
	
func equip_perk(item) -> void:
	_data.inventory_hud["perks"].append(item)
	_data.inventory_changed.emit(_data.inventory_hud)

@rpc("any_peer", "call_local", "reliable")
func request_debug_add_dung(amount: int) -> void:
	if not multiplayer.is_server():
		return

	var sender_id := multiplayer.get_remote_sender_id()
	if sender_id == 0:
		sender_id = multiplayer.get_unique_id()

	var player_data: Statics.PlayerData = Game.get_player(sender_id)
	if player_data == null:
		return

	Game.set_player_dung(sender_id, player_data.dung + amount)

func get_HUD() -> CanvasLayer: return hud

func get_HB() -> ProgressBar: return health_bar
