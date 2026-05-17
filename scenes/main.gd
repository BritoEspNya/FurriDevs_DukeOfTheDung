extends Node2D

@export var player_scene: PackedScene
@export var ball_scene: PackedScene
@onready var players: Node2D = $World/Players
@onready var balls: Node2D = $Balls
@onready var spawn_points: Node2D = $PlayerSpawnPoints
@onready var ball_spawn_points: Node2D = $BallSpawnPoints
@onready var match_controller: MatchController = $MatchController

var player_instances: Array[Node] = []
var ball_instances: Array[Node] = []

func _ready() -> void:
	_spawn_match_entities()

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
		
		var ball_instance = ball_scene.instantiate()
		balls.add_child(ball_instance, true)
		
		ball_instances.append(ball_instance) # Agregamos la bola
		
		var ball_spawn_point = ball_spawn_points.get_child(i)
		ball_instance.global_position = ball_spawn_point.global_position

func _setup_match_controller() -> void:
	match_controller.setup(player_instances, ball_instances)

func _process(delta: float) -> void:
	pass
