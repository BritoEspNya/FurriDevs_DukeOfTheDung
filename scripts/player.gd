class_name Player
extends CharacterBody2D

@export var speed: int = 200
@export var acceleration: float = 400

var _data: Statics.PlayerData

@onready var label: Label = $Label
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var camera_2d: Camera2D = $Camera2D

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		var move_input = Input.get_vector("input_left", "input_right", "input_up", "input_down")
		velocity.x = move_toward(velocity.x, move_input.x * speed, acceleration * delta)
		velocity.y = move_toward(velocity.y, move_input.y * speed, acceleration * delta)
		move_and_slide()

func setup(data: Statics.PlayerData) -> void:
	_data = data
	name = str(data.id)
	label.text = data.name
	set_multiplayer_authority(data.id, false)
	multiplayer_synchronizer.set_multiplayer_authority(data.id, false)
	camera_2d.enabled = is_multiplayer_authority()
