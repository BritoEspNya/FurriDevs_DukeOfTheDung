extends StaticBody2D

var _near_players: Array[Node2D]
var attached_player: Player
var is_attached: bool = false

var distance: float = 200
var follow_speed: float = 8.0

@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	if multiplayer.is_server():
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
			if attached_player == player:
				if !is_attached:
					attach()
				else:
					detach()
				attached_player.input_synchronizer.mode_input = !attached_player.input_synchronizer.mode_input
			else:
				attached_player = player

func attach() -> void:
	set_collision_mask_value(1, false)
	set_collision_layer_value(1, false)
	is_attached = true
	
func detach() -> void:
	set_collision_mask_value(1, true)
	set_collision_layer_value(1, true)
	is_attached = false

func _on_body_entered(body: Node2D) -> void:
	Debug.log("Player entered ball space")
	var player = body as Player
	_near_players.push_back(player)

func _on_body_exit(body: Node2D) -> void:
	Debug.log("Player exit ball space")
	_near_players.erase(body)
