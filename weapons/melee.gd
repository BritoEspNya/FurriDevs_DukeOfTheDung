extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@rpc("any_peer", "call_local", "reliable")
func attack() -> void:
	animation_player.play("attack")
	
