extends Node2D

@export var player_scene: PackedScene
@export var ball_scene: PackedScene
@export var dung_resource_scenes: Array[PackedScene]

@onready var players: Node2D = $World/Players
@onready var balls: Node2D = $Balls
@onready var spawn_points: Node2D = $PlayerSpawnPoints
@onready var ball_spawn_points: Node2D = $BallSpawnPoints
@onready var match_controller: MatchController = $MatchController
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner


var player_instances: Array[Node] = []
var ball_instances: Array[Node] = []

func _ready() -> void:
	_spawn_match_entities()
	_setup_match_controller()

func _spawn_match_entities() -> void:
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_instance = player_scene.instantiate()
		players.add_child(player_instance, true)
		
		player_instances.append(player_instance) # Agregamos el player
		
		var player_spawn_point = spawn_points.get_child(i)
		player_instance.global_position = player_spawn_point.global_position
		player_instance.setup(player_data)
		player_data.scene = player_instance
		player_instance.respawned.connect(_on_player_respawn.bind(player_instance, player_spawn_point))
		player_instance.died.connect(_on_player_died.bind(player_instance))
		
		var ball_instance = ball_scene.instantiate()
		balls.add_child(ball_instance, true)
		
		ball_instances.append(ball_instance) # Agregamos la bola
		
		ball_instance.global_position = player_instance.ball_point.global_position
		ball_instance.attached_player = player_instance

func _setup_match_controller() -> void:
	match_controller.setup(player_instances, ball_instances, spawn_points)

func _process(delta: float) -> void:
	pass

func _on_player_respawn(player: Player, spawn_point: Node2D) -> void:
	#if not multiplayer.is_server():
		#return
	#player.global_position = spawn_point.global_position
	# Aplicamos una posición aleatoria?
	player.apply_respawn_position(spawn_point.global_position)

func _on_player_died(player: Player) -> void:
	if not multiplayer.is_server():
		return
	var total_dung = player.get_dung()
	var little_resource_quant: int = 1
	var big_resource_quant: int = 3
	
	var dropped_dung: int = total_dung/3
	var n_big_resources: int = dropped_dung / big_resource_quant
	var m_little_resources: int = (dropped_dung % big_resource_quant) / little_resource_quant
	Game.set_player_dung(player.get_id(), total_dung - dropped_dung)
	# resources = [little_resource, big_resource]
	var deb_cnt: int = 0
	while n_big_resources > 0:
		while m_little_resources > 0:
			spawn_dung_resource(0, player, 75)
			m_little_resources -= 1
			deb_cnt += 1
		spawn_dung_resource(1, player, 75)
		n_big_resources -= 1
		deb_cnt += 1
	var deb: String = "Se han spawneado "+str(deb_cnt)+" cacas OMG"
	Debug.log(deb)
	
func spawn_dung_resource(resource_type: int, player_s: Player, range: int) -> void:
	# "Cuadrado"
	var resource_ins
	if resource_type == 0:
		resource_ins = dung_resource_scenes.get(0).instantiate()
	else:
		resource_ins = dung_resource_scenes.get(1).instantiate()
	resource_ins.global_position = player_s.global_position + Vector2(randf_range(-range, range), randf_range(-range, range))
	multiplayer_spawner.call_deferred("add_child", resource_ins, true)
	#var deb: String = "Hemos spawneado el recurso: "+str(resource_ins)
	#Debug.log(deb)
