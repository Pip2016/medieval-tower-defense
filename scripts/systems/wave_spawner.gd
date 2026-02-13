class_name WaveSpawner
extends Node

## Handles spawning enemies for a wave based on WaveData configuration.

signal enemy_spawned(enemy: Node3D)
signal spawn_group_finished()

var spawn_point: Vector3 = Vector3.ZERO
var enemy_path: WaypointPath
var enemy_container: Node3D
var _active_spawns: int = 0


func setup(start_pos: Vector3, path: WaypointPath, container: Node3D) -> void:
	spawn_point = start_pos
	enemy_path = path
	enemy_container = container


func spawn_wave(wave_data: WaveData, wave_number: int) -> void:
	_active_spawns = wave_data.enemy_spawns.size()

	for spawn_data in wave_data.enemy_spawns:
		_spawn_group(spawn_data, wave_number)


func _spawn_group(spawn_data: EnemySpawnData, wave_number: int) -> void:
	if spawn_data.start_delay > 0:
		await get_tree().create_timer(spawn_data.start_delay).timeout

	for i in range(spawn_data.count):
		if not is_inside_tree():
			return
		_spawn_single_enemy(spawn_data.enemy_data, wave_number)
		if i < spawn_data.count - 1:
			await get_tree().create_timer(spawn_data.spawn_interval).timeout

	_active_spawns -= 1
	if _active_spawns <= 0:
		spawn_group_finished.emit()


func _spawn_single_enemy(data: EnemyData, wave_number: int) -> void:
	if enemy_container == null or enemy_path == null:
		return

	var enemy := _create_enemy_node()
	enemy_container.add_child(enemy)

	var controller: EnemyController = enemy.get_node("EnemyController") if enemy.has_node("EnemyController") else enemy
	if controller is EnemyController:
		controller.initialize(data, enemy_path, wave_number)

	GameState.register_enemy()
	GameEvents.enemy_spawned.emit(enemy)
	enemy_spawned.emit(enemy)


func _create_enemy_node() -> CharacterBody3D:
	var enemy := CharacterBody3D.new()
	enemy.collision_layer = 4  # Layer 3: enemies
	enemy.collision_mask = 1   # Layer 1: environment

	# Add collision shape
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.5
	collision.shape = shape
	collision.position.y = 0.75
	enemy.add_child(collision)

	# Add enemy controller script
	var controller := EnemyController.new()
	controller.name = "EnemyController"
	enemy.add_child(controller)

	# Add health component
	var health := EnemyHealth.new()
	health.name = "EnemyHealth"
	enemy.add_child(health)

	# Add path follower
	var path_follower := PathFollower.new()
	path_follower.name = "PathFollower"
	enemy.add_child(path_follower)

	# Add visual body
	var body := MeshInstance3D.new()
	body.name = "Body"
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.4
	capsule.height = 1.2
	body.mesh = capsule
	body.position.y = 0.75
	enemy.add_child(body)

	# Add health bar
	var health_bar := _create_health_bar()
	health_bar.position.y = 1.8
	enemy.add_child(health_bar)

	return enemy


func _create_health_bar() -> Node3D:
	var container := Node3D.new()
	container.name = "HealthBar"

	# Background
	var bg := MeshInstance3D.new()
	bg.name = "Background"
	var bg_mesh := PlaneMesh.new()
	bg_mesh.size = Vector2(1.0, 0.12)
	bg.mesh = bg_mesh
	bg.rotation.x = -PI / 2
	var bg_mat := StandardMaterial3D.new()
	bg_mat.albedo_color = Color(0.2, 0.0, 0.0, 0.8)
	bg_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bg_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bg_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	bg.set_surface_override_material(0, bg_mat)
	container.add_child(bg)

	# Fill
	var fill := MeshInstance3D.new()
	fill.name = "Fill"
	var fill_mesh := PlaneMesh.new()
	fill_mesh.size = Vector2(0.96, 0.08)
	fill.mesh = fill_mesh
	fill.rotation.x = -PI / 2
	fill.position.z = -0.001
	var fill_mat := StandardMaterial3D.new()
	fill_mat.albedo_color = Color(0.0, 0.9, 0.0, 0.9)
	fill_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fill_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fill_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	fill.set_surface_override_material(0, fill_mat)
	container.add_child(fill)

	return container
