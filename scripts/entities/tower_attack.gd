class_name TowerAttack
extends Node3D

## Handles tower attack logic, cooldowns, and projectile creation.

var damage: float = 10.0
var attack_speed: float = 1.0
var cooldown: float = 0.0
var projectile_color: Color = Color.YELLOW
var projectile_speed: float = 20.0
var projectile_size: float = 0.15
var targeting: TowerTargeting


func initialize(dmg: float, aspd: float, proj_color: Color, proj_speed: float, proj_size: float) -> void:
	damage = dmg
	attack_speed = aspd
	projectile_color = proj_color
	projectile_speed = proj_speed
	projectile_size = proj_size

	# Find sibling targeting component
	await get_tree().process_frame
	if get_parent().has_node("Targeting"):
		targeting = get_parent().get_node("Targeting") as TowerTargeting


func update_stats(new_damage: float, new_speed: float) -> void:
	damage = new_damage
	attack_speed = new_speed


func _process(delta: float) -> void:
	if targeting == null:
		return

	cooldown -= delta

	var target: Node3D = targeting.select_target()
	if target and cooldown <= 0:
		_fire_at(target)
		cooldown = 1.0 / attack_speed


func _fire_at(target: Node3D) -> void:
	if not is_instance_valid(target):
		return

	var projectile := _create_projectile()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position + Vector3(0, 1.5, 0)

	var target_pos: Vector3 = target.global_position + Vector3(0, 0.75, 0)
	var distance: float = projectile.global_position.distance_to(target_pos)
	var travel_time: float = distance / projectile_speed

	var tween: Tween = projectile.create_tween()
	tween.tween_property(projectile, "global_position", target_pos, travel_time)
	tween.tween_callback(func():
		_apply_damage(target)
		projectile.queue_free()
	)


func _apply_damage(target: Node3D) -> void:
	if not is_instance_valid(target):
		return
	if target.has_node("EnemyHealth"):
		var health: EnemyHealth = target.get_node("EnemyHealth")
		health.take_damage(damage)


func _create_projectile() -> MeshInstance3D:
	var projectile := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = projectile_size
	sphere.height = projectile_size * 2.0
	projectile.mesh = sphere

	var mat := StandardMaterial3D.new()
	mat.albedo_color = projectile_color
	mat.emission_enabled = true
	mat.emission = projectile_color
	mat.emission_energy_multiplier = 3.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	projectile.set_surface_override_material(0, mat)

	return projectile
