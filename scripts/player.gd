extends CharacterBody2D

@export var speed: int = 200
@export var acceleration: float = 400

func _physics_process(delta: float) -> void:
	var move_input = Input.get_vector("input_left", "input_right", "input_up", "input_down")
	velocity.x = move_toward(velocity.x, move_input.x * speed, acceleration * delta)
	velocity.y = move_toward(velocity.y, move_input.y * speed, acceleration * delta)
	move_and_slide()

