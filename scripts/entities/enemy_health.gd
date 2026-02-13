class_name EnemyHealth
extends Node

## Health component for enemies. Handles damage, resistances, and status effects.

signal health_changed(current: float, max_hp: float)
signal died

var max_health: float = 100.0
var current_health: float = 100.0
var enemy_data: EnemyData

# Status effects
var active_effects: Array[Dictionary] = []
var is_stunned: bool = false
var speed_modifier: float = 1.0


func initialize(health: float, data: EnemyData) -> void:
	max_health = health
	current_health = health
	enemy_data = data
	active_effects.clear()
	is_stunned = false
	speed_modifier = 1.0


func take_damage(amount: float, damage_type: int = 0) -> void:
	if current_health <= 0:
		return

	var resistance: float = 0.0
	if enemy_data:
		resistance = enemy_data.get_resistance(damage_type)

	var actual_damage: float = amount * (1.0 - clampf(resistance, 0.0, 0.9))
	current_health -= actual_damage
	current_health = maxf(current_health, 0.0)

	health_changed.emit(current_health, max_health)
	GameEvents.enemy_damaged.emit(get_parent(), actual_damage, current_health)

	if current_health <= 0:
		died.emit()


func apply_effect(effect: AbilityEffect) -> void:
	var effect_data: Dictionary = {
		"type": effect.effect_type,
		"value": effect.value,
		"duration": effect.duration,
		"remaining": effect.duration,
		"tick_timer": 0.0,
		"tick_interval": effect.tick_interval,
	}
	active_effects.append(effect_data)
	_update_effect_state()


func _process(delta: float) -> void:
	if active_effects.is_empty():
		return

	var effects_to_remove: Array[int] = []

	for i in range(active_effects.size()):
		var effect: Dictionary = active_effects[i]
		effect["remaining"] -= delta

		if effect["remaining"] <= 0:
			effects_to_remove.append(i)
			continue

		match effect["type"]:
			AbilityEffect.EffectType.DOT:
				effect["tick_timer"] += delta
				if effect["tick_timer"] >= effect["tick_interval"]:
					effect["tick_timer"] = 0.0
					take_damage(effect["value"], 2)  # Fire damage

			AbilityEffect.EffectType.SLOW:
				pass  # Applied continuously via _update_effect_state

			AbilityEffect.EffectType.STUN:
				pass  # Applied continuously

	# Remove expired effects (reverse order)
	for i in range(effects_to_remove.size() - 1, -1, -1):
		active_effects.remove_at(effects_to_remove[i])

	_update_effect_state()


func _update_effect_state() -> void:
	is_stunned = false
	speed_modifier = 1.0

	for effect in active_effects:
		match effect["type"]:
			AbilityEffect.EffectType.SLOW:
				speed_modifier = minf(speed_modifier, 1.0 - effect["value"])
			AbilityEffect.EffectType.STUN:
				is_stunned = true
				speed_modifier = 0.0


func get_health_ratio() -> float:
	return current_health / max_health if max_health > 0 else 0.0
