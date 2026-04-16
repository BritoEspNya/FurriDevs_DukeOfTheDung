class_name HitboxComponent
extends Area2D

@export var damage_amount: int = 10
@export var damage_type: StringName = &"default"
@export var one_shot_per_target: bool = true

var source_peer_id: int = -1
var hit_targets: Array[Node] = []

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if not (area is HurtboxComponent):
		return

	var hurtbox := area as HurtboxComponent

	if one_shot_per_target and hit_targets.has(hurtbox):
		return

	var data := DamageDataResource.new()
	data.amount = damage_amount
	data.source_peer_id = source_peer_id
	data.source_node_path = get_path()
	data.damage_type = damage_type

	hurtbox.receive_hit(data)
	hit_targets.append(hurtbox)
