extends CanvasLayer

@onready var dung: Label = %Dung


func _ready() -> void:
	await get_tree().process_frame
	var player_name: String = get_parent()._data.name
	var current_player_data: Statics.PlayerData
	var player := get_parent() as Player
	
	if not player.is_multiplayer_authority():
		hide()
		return
	
	for data: Statics.PlayerData in Game.players:
		if data.name == player_name:
			current_player_data = data
			break
	dung.text = str(current_player_data.dung)
	current_player_data.dung_changed.connect(_on_dung_changed)

func _on_dung_changed(value:int) -> void:
	dung.text = str(value)
	
