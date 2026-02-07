class_name EnemyController
extends Node

## Main enemy controller. Coordinates path following, health, and visuals.

var enemy_data: EnemyData
var wave_number: int = 1
var path_follower: PathFollower
var health_component: EnemyHealth
var body: CharacterBody3D


func _ready() -> void:
	body = get_parent() as CharacterBody3D


func initialize(data: EnemyData, path: WaypointPath, wave: int) -> void:
	enemy_data = data
	wave_number = wave

	var stats: Dictionary = data.get_scaled_stats(wave)

	# Setup path follower
	if body and body.has_node("PathFollower"):
		path_follower = body.get_node("PathFollower") as PathFollower
		path_follower.setup(path, stats["speed"])
		path_follower.path_completed.connect(_on_reached_end)
		body.global_position = path.waypoints[0] if not path.waypoints.is_empty() else Vector3.ZERO

	# Setup health
	if body and body.has_node("EnemyHealth"):
		health_component = body.get_node("EnemyHealth") as EnemyHealth
		health_component.initialize(stats["health"], data)
		health_component.died.connect(_on_died)
		health_component.health_changed.connect(_on_health_changed)

	_apply_visuals()


func _apply_visuals() -> void:
	if body == null or enemy_data == null:
		return

	if body.has_node("Body"):
		var mesh: MeshInstance3D = body.get_node("Body")
		var mat := StandardMaterial3D.new()
		mat.albedo_color = enemy_data.body_color
		mesh.set_surface_override_material(0, mat)
		mesh.scale = Vector3.ONE * enemy_data.body_scale


func _on_died() -> void:
	if body and enemy_data:
		var stats: Dictionary = enemy_data.get_scaled_stats(wave_number)
		GameEvents.enemy_killed.emit(body, stats["gold_reward"])
		body.queue_free()


func _on_reached_end() -> void:
	if body and enemy_data:
		GameEvents.enemy_reached_end.emit(body, enemy_data.lives_cost)
		body.queue_free()


func _on_health_changed(current: float, max_hp: float) -> void:
	if body == null:
		return
	# Update health bar
	if body.has_node("HealthBar"):
		var health_bar: Node3D = body.get_node("HealthBar")
		if health_bar.has_node("Fill"):
			var fill: MeshInstance3D = health_bar.get_node("Fill")
			var ratio: float = clampf(current / max_hp, 0.0, 1.0)
			fill.scale.x = ratio
			fill.position.x = -(1.0 - ratio) * 0.48

			var mat: StandardMaterial3D = fill.get_surface_override_material(0)
			if mat:
				if ratio > 0.6:
					mat.albedo_color = Color(0.0, 0.9, 0.0, 0.9)
				elif ratio > 0.3:
					mat.albedo_color = Color(0.9, 0.9, 0.0, 0.9)
				else:
					mat.albedo_color = Color(0.9, 0.0, 0.0, 0.9)
