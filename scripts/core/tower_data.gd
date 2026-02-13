@tool
class_name TowerData
extends Resource

## Data resource defining tower stats, upgrades, and behavior.

enum TowerType { ARCHER, MAGE, CANNON, BARRACKS }

@export_category("Identity")
@export var tower_name: String = "Tower"
@export var tower_type: TowerType = TowerType.ARCHER
@export_multiline var description: String = ""

@export_category("Base Stats")
@export var base_cost: int = 100
@export var base_range: float = 150.0
@export var base_damage: float = 10.0
@export var base_attack_speed: float = 1.0

@export_category("Visuals")
@export var tower_color: Color = Color.WHITE
@export var projectile_color: Color = Color.YELLOW
@export var projectile_speed: float = 20.0
@export var projectile_size: float = 0.15

@export_category("Upgrades")
@export var upgrades: Array[TowerUpgradeData] = []
@export var max_level: int = 3


func get_stats_at_level(level: int) -> Dictionary:
	var stats := {
		"damage": base_damage,
		"range": base_range,
		"attack_speed": base_attack_speed,
		"cost": base_cost,
	}
	for i in range(mini(level - 1, upgrades.size())):
		var upgrade: TowerUpgradeData = upgrades[i]
		stats["damage"] *= upgrade.damage_multiplier
		stats["range"] *= upgrade.range_multiplier
		stats["attack_speed"] *= upgrade.speed_multiplier
	return stats


func get_upgrade_cost(current_level: int) -> int:
	if current_level - 1 < upgrades.size():
		return upgrades[current_level - 1].upgrade_cost
	return -1
