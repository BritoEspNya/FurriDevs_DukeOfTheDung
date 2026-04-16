class_name HurtboxComponent
extends Area2D

signal damage_received(data: DamageDataResource)

@export var health_component_path: NodePath

@export var is_enabled: bool = true

@onready var health_component: HealthComponent = get_node_or_null(health_component_path)

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	var hitbox: HitboxComponent = area as HitboxComponent
	if hitbox and health_component:
		health_component.take_damage(null)
func receive_hit(data: DamageDataResource) -> void:
	if not is_enabled:
		return
	if health_component == null:
		return

	damage_received.emit(data)
	health_component.take_damage(data)
