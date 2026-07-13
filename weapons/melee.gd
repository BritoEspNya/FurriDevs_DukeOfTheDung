extends Weapon

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@rpc("any_peer", "call_local", "reliable")
func main_attack() -> void:
	animation_player.play("attack")
	
