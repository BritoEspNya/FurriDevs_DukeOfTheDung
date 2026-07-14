class_name Projectile
extends Area2D

@export var speed: int = 500
@export var hitbox_component: HitboxComponent

var damage: float = 0.0

func setup(projectile_damage: float, projectile_owner: Node2D) -> void:
	damage = maxf(projectile_damage, 0.0)
	if hitbox_component == null:
		Debug.log("%s no tiene una HitboxComponent asignada." % name)
		return
	hitbox_component.set_damage(damage)
	hitbox_component.source_owner = projectile_owner

func _ready() -> void:
	await get_tree().create_timer(2).timeout
	if multiplayer and multiplayer.is_server(): #multiplayer.is_server():
		queue_free()
 
func _physics_process(delta: float) -> void:
	var direction: Vector2 = global_transform.x
	global_position += direction * speed * delta
