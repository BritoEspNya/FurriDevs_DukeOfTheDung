extends StaticBody2D

var _player: Player
var attached_to_player: bool = false

@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	if multiplayer.is_server():
		area_2d.body_entered.connect(_on_body_entered)
		area_2d.body_exited.connect(_on_body_exit)
		
func _physics_process(delta: float) -> void:
	if attached_to_player:
		self.global_position = _player.global_position + Vector2(10,10)
		
func _input(event: InputEvent) -> void:
	var player: Player = Game.get_current_player().scene
	if event.is_action_pressed("input_movement_mode") and _player == player:
		attached_to_player = !attached_to_player
		_player.input_synchronizer.mode_input = !_player.input_synchronizer.mode_input

func _on_body_entered(body: Node2D) -> void:
	Debug.log("Player entered ball space")
	var player = body as Player
	if player and !_player:
		_player = player

func _on_body_exit(body: Node2D) -> void:
	if _player:
		var player = body as Player
		if player == _player:
			_player = null
