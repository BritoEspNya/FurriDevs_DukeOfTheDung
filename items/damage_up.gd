extends ItemData

#@export var level: int = 1

func action(player: Player) -> void:
	player.level_up()

func equip(player:Player) -> void:
	player.equip_perk(self)
