class_name Player
extends CharacterBody2D

@export var walk_speed: int = 200
@export var flight_speed: int = 500
@export var acceleration: float = 400
@export var rotation_speed: float = 5
@export var projectile_scene: PackedScene

var _data: Statics.PlayerData
var _speed: int = walk_speed

@onready var label: Label = $Label
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var camera_2d: Camera2D = $Camera2D
@onready var input_synchronizer: InputSyncronizer = $InputSynchronizer
@onready var sync_timer: Timer = $SyncTimer
@onready var dung_recolected: int = 0
@onready var projectile_spawner: MultiplayerSpawner = $ProjectileSpawner
@onready var projectile_spawn_marker: Marker2D = $ProjectileSpawnMarker

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

func _ready() -> void:
	sync_timer.timeout.connect(_on_sync_timeout)
	if projectile_scene:
		projectile_spawner.add_spawnable_scene(projectile_scene.resource_path)

func _physics_process(delta: float) -> void:
	var move_input: Vector2 = input_synchronizer.move_input
	if input_synchronizer.flight_input:
		_speed = flight_speed
	else:
		_speed = walk_speed
	if input_synchronizer.mode_input:
		velocity.x = move_toward(velocity.x, move_input.x * _speed, acceleration * delta)
		velocity.y = move_toward(velocity.y, move_input.y * _speed, acceleration * delta)
		if velocity.length() > 0:
			var angle = velocity.angle() + PI / 2
			rotation = lerp_angle(rotation, angle, rotation_speed * delta)
	else:
		rotation += move_input.x * rotation_speed * delta
		var forward_direction = Vector2.UP.rotated(rotation)
		velocity = velocity.move_toward(forward_direction * _speed * move_input.y, acceleration * delta)
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("fire_main_weapon"):
			fire()
	move_and_slide()
	
	if input_synchronizer.move_input:
		playback.travel("walk")
	else:
		playback.travel("RESET")

func setup(data: Statics.PlayerData) -> void:
	_data = data
	name = str(data.id)
	label.text = data.name
	set_multiplayer_authority(data.id, false)
	input_synchronizer.set_multiplayer_authority(data.id, false)
	camera_2d.enabled = is_multiplayer_authority()
	if is_multiplayer_authority():
		sync_timer.start()

func fire() -> void:
	if not is_multiplayer_authority():
		return
	Debug.log("FIRE FIRE FIREE")
	var direction: Vector2 = projectile_spawn_marker.global_position.direction_to(get_global_mouse_position())
	fire_main_weapon.rpc_id(1, direction)

@rpc("authority", "call_remote", "unreliable_ordered")
func send_position(pos: Vector2) -> void:
	global_position = lerp(global_position, pos, 0.5)
	
@rpc("authority", "call_local")
func fire_main_weapon(direction: Vector2) -> void:
	if not projectile_scene:
		return
	var projectile_ins = projectile_scene.instantiate()
	projectile_ins.global_position = projectile_spawn_marker.global_position
	projectile_ins.global_rotation = direction.angle()
	projectile_spawner.add_child(projectile_ins, true)

func fire_one_shot(one_shot_name: String) -> void:
	#animation_tree["parameters/%s/request" % one_shot_name] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	pass

func _on_sync_timeout() -> void:
	send_position.rpc(global_position)
