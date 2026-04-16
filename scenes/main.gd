extends Node2D

@export var player_scene: PackedScene
@export var ball_scene: PackedScene
@onready var players: Node2D = $Players
@onready var balls: Node2D = $Balls
@onready var spawn_points: Node2D = $PlayerSpawnPoints
@onready var ball_spawn_points: Node2D = $BallSpawnPoints

func _ready() -> void:
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_instance = player_scene.instantiate()
		players.add_child(player_instance, true)
		var player_spawn_point = spawn_points.get_child(i)
		player_instance.global_position = player_spawn_point.global_position
		player_instance.setup(player_data)
		
		var ball_instance = ball_scene.instantiate()
		balls.add_child(ball_instance, true)
		var ball_spawn_point = ball_spawn_points.get_child(i)
		ball_instance.global_position = ball_spawn_point.global_position

func _process(delta: float) -> void:
	pass
