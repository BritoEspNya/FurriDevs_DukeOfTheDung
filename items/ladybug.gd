extends ItemData

@export var life: int = 10

func action(player: Player) -> void:
	player.increase_max_healt(life)

func equip(player:Player) -> void:
	player.equip_perk(self)
