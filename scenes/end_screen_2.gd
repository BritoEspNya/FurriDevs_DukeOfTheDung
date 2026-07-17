extends Control

@onready var podium_3: Sprite2D = $PanelContainer/Podium3
@onready var podium_1: Sprite2D = $PanelContainer/Podium1
@onready var podium_2: Sprite2D = $PanelContainer/Podium2
@onready var title: Label = $PanelContainer2/Label

@onready var player_1: Label = $PanelContainer/Podium1/Player1
@onready var score_1: Label = $PanelContainer/Podium1/Score1
@onready var player_2: Label = $PanelContainer/Podium2/Player2
@onready var score_2: Label = $PanelContainer/Podium2/Score2
@onready var player_3: Label = $PanelContainer/Podium3/Player3
@onready var score_3: Label = $PanelContainer/Podium3/Score3

var podium_player_tags: Array[Label]
var podium_score_tags: Array[Label]

func _ready() -> void:
	podium_player_tags = [player_3, player_2, player_1]
	podium_score_tags = [score_3, score_2, score_1]

func show_results() -> void:
	var limite_pantalla_y: float = get_viewport_rect().size.y
	
	var pos_final_title: Vector2 = title.position
	var pos_final_3: Vector2 = podium_3.position
	var pos_final_2: Vector2 = podium_2.position
	var pos_final_1: Vector2 = podium_1.position
	
	title.position.y = -limite_pantalla_y - 100
	podium_3.position.y = limite_pantalla_y + 200
	podium_2.position.y = limite_pantalla_y + 200
	podium_1.position.y = limite_pantalla_y + 300
	
	get_results()
	show_title(pos_final_title, limite_pantalla_y)
	show_podium(pos_final_3, pos_final_2, pos_final_1)

func show_title(pos_final, limite_y) -> void:
	var tween = create_tween()

	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(title, "position:y", pos_final.y, 1.0).set_delay(1.0)

	tween.tween_interval(2.0)
	
	tween.chain().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	var hidden_pos_y = -limite_y - 100
	tween.tween_property(title, "position:y", hidden_pos_y, 0.5).set_delay(2.0)

func show_podium(pos3: Vector2, pos2: Vector2, pos1: Vector2) -> void:
	var tween: Tween = create_tween()
	
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(podium_3, "position", pos3, 1.0).set_delay(2.0)
	tween.tween_property(podium_2, "position", pos2, 1.0).set_delay(1.0)
	tween.tween_property(podium_1, "position", pos1, 1.0).set_delay(1.0)
	
func get_results() -> void:
	var sorted_players: Array[Statics.PlayerData] = Game.players.duplicate()
	sorted_players.sort_custom(func(a, b): return a.dung > b.dung)
	
	var i: int = 2
	for player_data: Statics.PlayerData in sorted_players:
		var player_tag: Label = podium_player_tags[i]
		var score_tag: Label = podium_score_tags[i]
		player_tag.text = player_data.name
		score_tag.text = str(player_data.dung)
		i -= 1
	
