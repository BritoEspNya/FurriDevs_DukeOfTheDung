class_name MatchController
extends Node

signal state_changed(new_state: MatchState)

enum MatchState {
	GAME_STARTING,
	GAME_PLAYING,
	GAME_SHOP,
	GAME_ENDING
}

@onready var shop_screen: Control = $"../UI/ShopScreen"
@onready var round_timer: Timer = $"../Timers/RoundTimer"
@onready var shop_timer: Timer = $"../Timers/ShopTimer"

var current_state: MatchState = MatchState.GAME_STARTING

var players: Array[Node] = []
var balls: Array[Node] = []

func setup(match_players: Array[Node], match_balls: Array[Node]) -> void:
	players = match_players
	balls = match_balls

func _ready() -> void:
	shop_screen.hide()
	round_timer.timeout.connect(_on_round_timer_timeout)
	shop_timer.timeout.connect(_on_shop_timer_timeout)
	# OJO se debe haber ejecutado setup()
	start_match()

func start_match() -> void:
	change_state(MatchState.GAME_STARTING)
	start_round()

func start_round() -> void:
	change_state(MatchState.GAME_PLAYING)
	shop_screen.hide()
	_set_gameplay_enabled(true)
	round_timer.start()

func enter_shop() -> void:
	change_state(MatchState.GAME_SHOP)
	_set_gameplay_enabled(false)
	shop_screen.show()
	#if shop_screen.has_method("refresh_shop"):
	#	shop_screen.refresh_shop()
	shop_timer.start()

func exit_shop() -> void:
	shop_screen.hide()
	start_round()

func end_match() -> void:
	change_state(MatchState.GAME_ENDING)
	_set_gameplay_enabled(false)

func change_state(new_state: MatchState) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	state_changed.emit(new_state)


func _set_gameplay_enabled(enabled: bool) -> void:
	for player in players:
		if player.has_method("set_gameplay_enabled"):
			player.set_gameplay_enabled(enabled)

	for ball in balls:
		if ball.has_method("set_gameplay_enabled"):
			ball.set_gameplay_enabled(enabled)
			
func _on_round_timer_timeout() -> void:
	enter_shop()

func _on_shop_timer_timeout() -> void:
	exit_shop()
