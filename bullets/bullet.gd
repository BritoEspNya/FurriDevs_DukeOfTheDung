extends Area2D

@export var speed: int = 500

func _ready() -> void:
	await get_tree().create_timer(2).timeout
	if is_multiplayer_authority(): #multiplayer.is_server():
		queue_free()
 
func _physics_process(delta: float) -> void:
	var direction: Vector2 = global_transform.x
	global_position += direction * speed * delta
