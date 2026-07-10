extends ItemData

@export var armor: int = 1

func action(player: Player) -> void:
	player.increase_armor(armor)

func equip(player:Player) -> void:
	player.equip_armor(self)
