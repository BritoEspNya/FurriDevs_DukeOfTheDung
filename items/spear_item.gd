extends ItemData

func action(player: Player) -> void:
	pass

func equip(player:Player) -> void:
	Debug.log("llamando a equip de arma")
	player.equip_weapon(self)
