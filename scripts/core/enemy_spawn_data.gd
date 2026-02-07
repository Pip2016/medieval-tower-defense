@tool
class_name EnemySpawnData
extends Resource

## Defines a group of enemies to spawn within a wave.

@export var enemy_data: EnemyData
@export var count: int = 5
@export var spawn_interval: float = 0.8
@export var start_delay: float = 0.0
@export var spawn_path_index: int = 0
