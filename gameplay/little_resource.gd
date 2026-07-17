class_name LittleResource
extends Area2D

@export var dung_quantity: int = 1

func _ready() -> void:
	if is_multiplayer_authority():
		body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D) -> void:
	var ball: Ball = body as Ball
	if ball:
		var player: Player = ball.attached_player
		if player:
			Game.set_player_dung(player.get_id(), Game.get_player_dung(player.get_id()) + dung_quantity)
			destroy.rpc()

@rpc("call_local","reliable")
func destroy() -> void: 
	queue_free()
