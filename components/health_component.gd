class_name HealthComponent
extends Node

signal health_changed(current: int, max_health: int)
signal damaged(data: DamageDataResource)
signal healed(amount: int)
signal died(data: DamageDataResource)

@export var health: int = 100:
	set(value):
		health = clamp(value, 0, max_health)
		if health == 0:
			died.emit()
			
@export var max_health: int = 100
var current_health: int

func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

func take_damage(data: DamageDataResource) -> void:
	if data == null:
		return
	if current_health < 0:
		return
	if data.amount <= 0:
		return

	current_health = max(current_health - data.amount, 0)
	damaged.emit(data)
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		died.emit(data)

func heal(amount: int) -> void:
	if amount <= 0:
		return
	if current_health <= 0:
		return

	current_health = min(current_health + amount, max_health)
	healed.emit(amount)
	health_changed.emit(current_health, max_health)

func reset_health() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

func is_dead() -> bool:
	return current_health <= 0
