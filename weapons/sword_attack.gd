extends Projectile

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	attack_animation.rpc()
	animation_player.animation_finished.connect(_on_attack_end)

@rpc("authority", "call_local", "reliable")
func attack_animation() -> void:
	animation_player.play("sword_attack")
	
func _on_attack_end(anim_name: StringName) -> void:
	if anim_name == "sword_attack":
		if multiplayer and multiplayer.is_server(): #multiplayer.is_server():
			queue_free()

func _physics_process(delta: float) -> void:
	pass
