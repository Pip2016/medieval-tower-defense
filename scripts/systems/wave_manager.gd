class_name WaveManager
extends Node

## Manages wave progression, timing, and completion checks.

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_done()

@export var waves: Array[WaveData] = []

var current_wave_index: int = -1
var spawner: WaveSpawner
var _checking_completion: bool = false


func _ready() -> void:
	spawner = WaveSpawner.new()
	spawner.name = "WaveSpawner"
	add_child(spawner)
	spawner.spawn_group_finished.connect(_on_spawn_group_finished)
	GameEvents.wave_enemies_remaining.connect(_on_enemies_remaining)


func start_next_wave() -> void:
	if GameState.is_game_over or GameState.is_game_won:
		return

	current_wave_index += 1
	if current_wave_index >= waves.size():
		all_waves_done.emit()
		GameEvents.all_waves_completed.emit()
		return

	GameState.current_wave = current_wave_index + 1
	GameState.is_wave_active = true
	_checking_completion = false

	var wave_data: WaveData = waves[current_wave_index]
	GameEvents.wave_started.emit(current_wave_index + 1)
	wave_started.emit(current_wave_index + 1)

	spawner.spawn_wave(wave_data, current_wave_index + 1)


func get_current_wave_number() -> int:
	return current_wave_index + 1


func get_total_waves() -> int:
	return waves.size()


func _on_spawn_group_finished() -> void:
	_checking_completion = true
	_check_wave_complete()


func _on_enemies_remaining(count: int) -> void:
	if _checking_completion and count <= 0:
		_complete_wave()


func _check_wave_complete() -> void:
	if GameState.enemies_alive <= 0:
		_complete_wave()


func _complete_wave() -> void:
	if not GameState.is_wave_active:
		return

	_checking_completion = false
	GameState.is_wave_active = false
	var wave_number: int = current_wave_index + 1
	var bonus: int = 0

	if current_wave_index < waves.size():
		bonus = waves[current_wave_index].completion_gold

	GameEvents.wave_completed.emit(wave_number, bonus)
	wave_completed.emit(wave_number)
