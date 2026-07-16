class_name Weapon 
extends Node2D

@export var attack_scene: PackedScene
@export var attack_cooldown: float = 0.3
#@export var projectile_damage: float
@export_category("Damage")
@export_range(0.0, 1000.0, 1, "or_greater")
var base_damage: float = 10.0
var buff_damage: float = 0.0
var base_muultiplier: float = 1.0

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
	
func get_attack_damage() -> float:
	return (base_damage*base_muultiplier)+buff_damage

func add_attack_damage(buff: float) -> void:
	buff_damage = buff
	
func add_mult_base_damage(mult: float) -> void:
	base_muultiplier += mult

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
	attack_ins.setup(get_attack_damage(), owner_player)
	attack_ins.global_position = attack_spawn_marker.global_position
	attack_ins.global_rotation = attack_spawn_marker.global_rotation
	owner_player.attack_spawner.add_child(attack_ins, true)
