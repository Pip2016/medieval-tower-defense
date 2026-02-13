@tool
class_name EnemyData
extends Resource

## Data resource defining enemy stats, scaling, and type.

enum EnemyType { GROUND, FLYING, ARMORED, BOSS }

@export_category("Identity")
@export var enemy_name: String = "Enemy"
@export var enemy_type: EnemyType = EnemyType.GROUND
@export_multiline var description: String = ""

@export_category("Base Stats")
@export var base_health: float = 100.0
@export var base_speed: float = 50.0
@export var base_armor: float = 0.0
@export var gold_reward: int = 10
@export var lives_cost: int = 1

@export_category("Scaling")
@export var health_scaling: float = 1.15
@export var speed_scaling: float = 1.05
@export var armor_scaling: float = 1.0

@export_category("Resistances")
@export var physical_resistance: float = 0.0
@export var magic_resistance: float = 0.0
@export var fire_resistance: float = 0.0

@export_category("Visuals")
@export var body_color: Color = Color.RED
@export var body_scale: float = 1.0


func get_scaled_stats(wave_number: int) -> Dictionary:
	var scale_factor: int = wave_number - 1
	return {
		"health": base_health * pow(health_scaling, scale_factor),
		"speed": base_speed * pow(speed_scaling, mini(scale_factor, 10)),
		"armor": base_armor * pow(armor_scaling, scale_factor),
		"gold_reward": gold_reward + (wave_number / 3),
	}


func get_resistance(damage_type: int) -> float:
	match damage_type:
		0: return physical_resistance
		1: return magic_resistance
		2: return fire_resistance
	return 0.0
