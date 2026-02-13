@tool
class_name TowerUpgradeData
extends Resource

## Data for a single tower upgrade level.

@export var upgrade_name: String = "Upgrade"
@export var upgrade_cost: int = 150
@export var damage_multiplier: float = 1.5
@export var range_multiplier: float = 1.1
@export var speed_multiplier: float = 1.0
@export_multiline var upgrade_description: String = ""
