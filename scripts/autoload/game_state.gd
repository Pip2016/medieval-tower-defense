extends Node

## Global game state singleton. Tracks gold, lives, wave progress.

const STARTING_GOLD: int = 300
const STARTING_LIVES: int = 20
const MAX_WAVES: int = 15

var gold: int = STARTING_GOLD:
	set(value):
		gold = maxi(value, 0)
		GameEvents.gold_changed.emit(gold)

var lives: int = STARTING_LIVES:
	set(value):
		lives = maxi(value, 0)
		GameEvents.lives_changed.emit(lives)
		if lives <= 0:
			is_game_over = true
			GameEvents.game_over.emit()

var current_wave: int = 0
var is_wave_active: bool = false
var is_game_over: bool = false
var is_game_won: bool = false
var is_paused: bool = false

var enemies_alive: int = 0
var total_kills: int = 0
var total_gold_earned: int = 0


func _ready() -> void:
	GameEvents.enemy_killed.connect(_on_enemy_killed)
	GameEvents.enemy_reached_end.connect(_on_enemy_reached_end)
	GameEvents.wave_completed.connect(_on_wave_completed)
	GameEvents.game_restarted.connect(reset)


func reset() -> void:
	gold = STARTING_GOLD
	lives = STARTING_LIVES
	current_wave = 0
	is_wave_active = false
	is_game_over = false
	is_game_won = false
	is_paused = false
	enemies_alive = 0
	total_kills = 0
	total_gold_earned = 0


func can_afford(cost: int) -> bool:
	return gold >= cost


func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		return true
	return false


func add_gold(amount: int) -> void:
	gold += amount
	total_gold_earned += amount


func lose_lives(amount: int) -> void:
	lives -= amount


func register_enemy() -> void:
	enemies_alive += 1


func unregister_enemy() -> void:
	enemies_alive -= 1
	GameEvents.wave_enemies_remaining.emit(enemies_alive)


func _on_enemy_killed(_enemy: Node3D, gold_reward: int) -> void:
	add_gold(gold_reward)
	total_kills += 1
	unregister_enemy()


func _on_enemy_reached_end(_enemy: Node3D, lives_cost: int) -> void:
	lose_lives(lives_cost)
	unregister_enemy()


func _on_wave_completed(wave_number: int, bonus_gold: int) -> void:
	add_gold(bonus_gold)
	is_wave_active = false
	if wave_number >= MAX_WAVES:
		is_game_won = true
		GameEvents.game_won.emit()
