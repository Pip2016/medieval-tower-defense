@tool
class_name WaveData
extends Resource

## Data resource defining a single wave of enemies.

@export_category("Wave Info")
@export var wave_number: int = 1
@export var is_boss_wave: bool = false
@export var completion_gold: int = 100

@export_category("Spawns")
@export var enemy_spawns: Array[EnemySpawnData] = []

@export_category("Timing")
@export var pre_wave_delay: float = 3.0
@export var post_wave_delay: float = 2.0


func get_total_enemies() -> int:
	var total: int = 0
	for spawn in enemy_spawns:
		total += spawn.count
	return total
