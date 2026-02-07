@tool
class_name AbilityData
extends Resource

## Data resource for hero abilities.

enum AbilityTargetType { POINT, ENEMY, SELF, ALL_ENEMIES_IN_RANGE }
enum DamageType { PHYSICAL, MAGIC, FIRE, HEAL }

@export_category("Identity")
@export var ability_name: String = "Ability"
@export_multiline var description: String = ""

@export_category("Stats")
@export var cooldown: float = 10.0
@export var ability_range: float = 200.0
@export var damage: float = 50.0
@export var damage_type: DamageType = DamageType.MAGIC
@export var area_of_effect: float = 0.0

@export_category("Targeting")
@export var target_type: AbilityTargetType = AbilityTargetType.POINT

@export_category("Effects")
@export var effects: Array[AbilityEffect] = []

@export_category("Visuals")
@export var effect_color: Color = Color.CYAN
@export var effect_duration: float = 0.5
