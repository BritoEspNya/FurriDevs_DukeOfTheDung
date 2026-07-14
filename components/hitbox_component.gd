class_name HitboxComponent
extends Area2D

@export var damage: float = 10.0
@export var source_owner: Node2D

func set_damage(value: float) -> void:
	damage = maxf(value, 0.0)
func get_damage() -> float:
	return damage
