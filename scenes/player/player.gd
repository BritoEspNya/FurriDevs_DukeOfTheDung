class_name Player
extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	health_component.died.connect(_on_died)
	health_component.damaged.connect(_on_damaged)

func _on_damaged(amount: int) -> void:
	print("Player recibió daño:", amount)

func _on_died() -> void:
	print("Player murió")
	queue_free() # temporal, luego esto será reemplazado por respawn


func fire(direction: Vector2) -> void:
	pass
	if not bullet_scene:
		return
	var bullet_inst = bullet_scene.instantiate()
