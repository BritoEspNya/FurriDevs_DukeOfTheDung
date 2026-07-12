extends ItemData

func action(player: Player) -> void:
	pass

func equip(player:Player) -> void:
	player.equip_weapon_inv(self)
