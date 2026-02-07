class_name AbilitySystem
extends Node

## Handles ability cooldowns, casting, and effect application.

var cooldown_timers: Dictionary = {}  # int (index) -> float (remaining)


func _process(delta: float) -> void:
	var keys_to_remove: Array = []
	for index in cooldown_timers:
		cooldown_timers[index] -= delta
		var ability: AbilityData = _get_ability_from_parent(index)
		if ability:
			GameEvents.ability_cooldown_updated.emit(index, maxf(cooldown_timers[index], 0.0), ability.cooldown)
		if cooldown_timers[index] <= 0:
			keys_to_remove.append(index)
			GameEvents.ability_ready.emit(index)

	for key in keys_to_remove:
		cooldown_timers.erase(key)


func is_ready(index: int) -> bool:
	return not cooldown_timers.has(index) or cooldown_timers[index] <= 0


func cast(ability_data: AbilityData, index: int, target_pos: Vector3) -> void:
	if not is_ready(index):
		return

	cooldown_timers[index] = ability_data.cooldown

	match ability_data.target_type:
		AbilityData.AbilityTargetType.POINT:
			_cast_at_point(ability_data, target_pos)
		AbilityData.AbilityTargetType.ALL_ENEMIES_IN_RANGE:
			_cast_aoe(ability_data, target_pos)
		AbilityData.AbilityTargetType.SELF:
			_cast_self(ability_data)
		AbilityData.AbilityTargetType.ENEMY:
			_cast_at_nearest_enemy(ability_data, target_pos)

	_create_visual_effect(ability_data, target_pos)


func _cast_at_point(ability_data: AbilityData, pos: Vector3) -> void:
	var enemies: Array = _get_enemies_in_area(pos, ability_data.area_of_effect if ability_data.area_of_effect > 0 else 1.0)
	for enemy in enemies:
		_apply_ability_to_enemy(ability_data, enemy)


func _cast_aoe(ability_data: AbilityData, pos: Vector3) -> void:
	var enemies: Array = _get_enemies_in_area(pos, ability_data.ability_range)
	for enemy in enemies:
		_apply_ability_to_enemy(ability_data, enemy)


func _cast_self(ability_data: AbilityData) -> void:
	# Buff nearby towers
	for effect in ability_data.effects:
		if effect.effect_type == AbilityEffect.EffectType.BUFF_TOWERS:
			pass  # Tower buff implementation


func _cast_at_nearest_enemy(ability_data: AbilityData, pos: Vector3) -> void:
	var enemies: Array = _get_enemies_in_area(pos, ability_data.ability_range)
	if enemies.size() > 0:
		_apply_ability_to_enemy(ability_data, enemies[0])


func _apply_ability_to_enemy(ability_data: AbilityData, enemy: Node3D) -> void:
	if not is_instance_valid(enemy):
		return

	# Apply direct damage
	if ability_data.damage > 0:
		if enemy.has_node("EnemyHealth"):
			var health: EnemyHealth = enemy.get_node("EnemyHealth")
			health.take_damage(ability_data.damage, ability_data.damage_type)

	# Apply status effects
	for effect in ability_data.effects:
		if enemy.has_node("EnemyHealth"):
			var health: EnemyHealth = enemy.get_node("EnemyHealth")
			health.apply_effect(effect)


func _get_enemies_in_area(center: Vector3, radius: float) -> Array:
	var result: Array = []
	var enemy_nodes: Array = get_tree().get_nodes_in_group("enemies") if get_tree() else []

	# Fallback: search scene for CharacterBody3D on enemy layer
	if enemy_nodes.is_empty() and get_tree():
		for node in get_tree().current_scene.get_children():
			if node.name == "EnemyContainer":
				for enemy in node.get_children():
					if is_instance_valid(enemy) and enemy.global_position.distance_to(center) <= radius:
						result.append(enemy)
				return result

	for enemy in enemy_nodes:
		if is_instance_valid(enemy) and enemy.global_position.distance_to(center) <= radius:
			result.append(enemy)

	return result


func _create_visual_effect(ability_data: AbilityData, pos: Vector3) -> void:
	var effect_visual := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	var radius: float = ability_data.area_of_effect if ability_data.area_of_effect > 0 else 1.0
	sphere.radius = radius
	sphere.height = radius * 2.0
	effect_visual.mesh = sphere
	effect_visual.global_position = pos + Vector3(0, 0.5, 0)

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(ability_data.effect_color, 0.4)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	effect_visual.set_surface_override_material(0, mat)

	get_tree().current_scene.add_child(effect_visual)

	var tween: Tween = effect_visual.create_tween()
	tween.tween_property(effect_visual, "scale", Vector3.ONE * 1.5, ability_data.effect_duration)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, ability_data.effect_duration)
	tween.tween_callback(effect_visual.queue_free)


func _get_ability_from_parent(index: int) -> AbilityData:
	var parent: Node = get_parent()
	if parent is HeroController and index < parent.abilities.size():
		return parent.abilities[index]
	return null
