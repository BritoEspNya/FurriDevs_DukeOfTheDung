class_name ProjectileWeapon 
extends Weapon

#@export var projectile_scene: PackedScene
#@onready var projectile_spawner: MultiplayerSpawner = $ProjectileSpawner
#@onready var projectile_spawn_marker: Marker2D = $ProjectileSpawnMarker
func get_attack_spawn_marker() -> Marker2D:
	return $ProjectileSpawnMarker

#func _ready() -> void:
	#if projectile_scene:
		#projectile_spawner.add_spawnable_scene(projectile_scene.resource_path)
#
#func main_attack() -> void:
	#Debug.log("FIRE FIRE FIREE")
	#fire_server.rpc_id(1)
#
#@rpc("any_peer", "call_local", "reliable")
#func fire_server() -> void:
	#if not projectile_scene:
		#return
	#var projectile_ins: Projectile = projectile_scene.instantiate()
	#projectile_ins.global_position = projectile_spawn_marker.global_position
	#projectile_ins.global_rotation = projectile_spawn_marker.global_rotation
	#projectile_spawner.add_child(projectile_ins, true)
