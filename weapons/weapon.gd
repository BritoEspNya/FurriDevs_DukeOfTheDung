class_name Weapon 
extends Node2D

@export var attack_scene: PackedScene
@export var attack_cooldown: float = 0.3

var attack_spawn_marker: Marker2D #= $AttackSpawnMarker
var owner_player: Player
var _can_attack: bool = true

func _ready() -> void:
	attack_spawn_marker = get_attack_spawn_marker()
	var node := get_parent()
	while node:
		if node is Player:
			owner_player = node
			owner_player.attack_spawner.add_spawnable_scene(attack_scene.resource_path)
			return
		node = node.get_parent()
	
func get_attack_spawn_marker() -> Marker2D:
	return $AttackSpawnMarker

func setup_weapon(player: Player) -> void:
	owner_player = player

func main_attack() -> void:
	if not _can_attack:
		return
	if attack_scene == null:
		Debug.log("Weapon has no attack_scene")
		return
	if owner_player == null:
		Debug.log("Weapon has no owner_player")
		return
	_can_attack = false
	main_attack_server.rpc_id(1)
	await get_tree().create_timer(attack_cooldown).timeout
	_can_attack = true
	

@rpc("any_peer", "call_local", "reliable")
func main_attack_server() -> void:
	if not attack_scene:
		return
	var attack_ins: Projectile = attack_scene.instantiate()
	for child in attack_ins.get_children():
		if child is HitboxComponent:
			var hitbox: HitboxComponent = child
			hitbox.source_owner = owner_player
			break
	attack_ins.global_position = attack_spawn_marker.global_position
	attack_ins.global_rotation = attack_spawn_marker.global_rotation
	owner_player.attack_spawner.add_child(attack_ins, true)
