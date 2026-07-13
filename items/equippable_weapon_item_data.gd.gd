class_name EquippableWeaponItemData
extends ItemData

@export var weapon_scene: PackedScene
@export var equip_on_pick: bool = true

func action(player: Player) -> void:
	pass

func equip(player:Player) -> void:
	Debug.log("llamando a equip de arma")
	player.equip_weapon(self)
