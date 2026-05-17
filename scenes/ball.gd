extends StaticBody2D

var _near_players: Array[Node2D]
var attached_player: Player
var is_attached: bool = false

var distance: float = 200
var follow_speed: float = 8.0

@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
		area_2d.body_entered.connect(_on_body_entered)
		area_2d.body_exited.connect(_on_body_exit)
		
func _physics_process(delta: float) -> void:
	if is_attached:
		var player_forward = Vector2.RIGHT.rotated(attached_player.global_rotation + PI/2)
		var target_pos = attached_player.global_position + (player_forward * distance)
		global_position = global_position.lerp(target_pos, follow_speed * delta)
		
func _input(event: InputEvent) -> void:
	var player: Player = Game.get_current_player().scene
	if event.is_action_pressed("input_movement_mode"):
		if _near_players.has(player):
			if !is_attached:
				attach.rpc(player.get_path())
			else:
				if player == attached_player:
					detach.rpc(player.get_path())
					
@rpc("any_peer", "call_local", "reliable")
func attach(player_path: NodePath) -> void:
	var player: Player = get_node(player_path)
	if !attached_player:
		attached_player = player
	if attached_player == player:
		set_collision_mask_value(1, false)
		set_collision_layer_value(1, false)
		is_attached = true
		player.input_synchronizer.mode_input = false

@rpc("any_peer", "call_local", "reliable")
func detach(player_path: NodePath) -> void:
	var player: Player = get_node(player_path)
	set_collision_mask_value(1, true)
	set_collision_layer_value(1, true)
	is_attached = false
	player.input_synchronizer.mode_input = true

func _on_body_entered(body: Node2D) -> void:
	Debug.log("Player entered ball space")
	var player = body as Player
	_near_players.push_back(player)

func _on_body_exit(body: Node2D) -> void:
	Debug.log("Player exit ball space")
	_near_players.erase(body)
