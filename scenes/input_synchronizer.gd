class_name InputSyncronizer
extends MultiplayerSynchronizer

@export var move_input: Vector2

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	move_input = Input.get_vector("input_left", "input_right", "input_up", "input_down")
		
