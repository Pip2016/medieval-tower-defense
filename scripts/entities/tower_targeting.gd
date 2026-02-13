class_name TowerTargeting
extends Node3D

## Handles tower target detection and selection via Area3D.

var current_target: Node3D
var enemies_in_range: Array[Node3D] = []
var detection_area: Area3D
var attack_range: float = 5.0

enum TargetPriority { FIRST, LAST, STRONGEST, WEAKEST, CLOSEST }
var priority: TargetPriority = TargetPriority.FIRST


func initialize(range_val: float) -> void:
	attack_range = range_val
	_create_detection_area()


func update_range(new_range: float) -> void:
	attack_range = new_range
	if detection_area:
		var collision: CollisionShape3D = detection_area.get_child(0)
		if collision and collision.shape is SphereShape3D:
			collision.shape.radius = attack_range


func select_target() -> Node3D:
	# Clean invalid refs
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e) and e.is_inside_tree())

	if enemies_in_range.is_empty():
		current_target = null
		return null

	match priority:
		TargetPriority.FIRST:
			current_target = _get_first_target()
		TargetPriority.LAST:
			current_target = _get_last_target()
		TargetPriority.STRONGEST:
			current_target = _get_strongest_target()
		TargetPriority.WEAKEST:
			current_target = _get_weakest_target()
		TargetPriority.CLOSEST:
			current_target = _get_closest_target()

	return current_target


func _get_first_target() -> Node3D:
	var best: Node3D = null
	var best_progress: float = -1.0
	for enemy in enemies_in_range:
		var follower: PathFollower = _get_path_follower(enemy)
		if follower and follower.current_distance > best_progress:
			best_progress = follower.current_distance
			best = enemy
	return best if best else enemies_in_range[0]


func _get_last_target() -> Node3D:
	var best: Node3D = null
	var best_progress: float = INF
	for enemy in enemies_in_range:
		var follower: PathFollower = _get_path_follower(enemy)
		if follower and follower.current_distance < best_progress:
			best_progress = follower.current_distance
			best = enemy
	return best if best else enemies_in_range[0]


func _get_strongest_target() -> Node3D:
	var best: Node3D = null
	var best_hp: float = -1.0
	for enemy in enemies_in_range:
		var health: EnemyHealth = _get_health(enemy)
		if health and health.current_health > best_hp:
			best_hp = health.current_health
			best = enemy
	return best if best else enemies_in_range[0]


func _get_weakest_target() -> Node3D:
	var best: Node3D = null
	var best_hp: float = INF
	for enemy in enemies_in_range:
		var health: EnemyHealth = _get_health(enemy)
		if health and health.current_health < best_hp:
			best_hp = health.current_health
			best = enemy
	return best if best else enemies_in_range[0]


func _get_closest_target() -> Node3D:
	var best: Node3D = null
	var best_dist: float = INF
	var tower_pos: Vector3 = global_position
	for enemy in enemies_in_range:
		var dist: float = tower_pos.distance_to(enemy.global_position)
		if dist < best_dist:
			best_dist = dist
			best = enemy
	return best if best else enemies_in_range[0]


func _get_path_follower(enemy: Node3D) -> PathFollower:
	if enemy.has_node("PathFollower"):
		return enemy.get_node("PathFollower") as PathFollower
	return null


func _get_health(enemy: Node3D) -> EnemyHealth:
	if enemy.has_node("EnemyHealth"):
		return enemy.get_node("EnemyHealth") as EnemyHealth
	return null


func _create_detection_area() -> void:
	detection_area = Area3D.new()
	detection_area.collision_layer = 0
	detection_area.collision_mask = 4  # Layer 3: enemies

	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = attack_range
	collision.shape = shape
	detection_area.add_child(collision)
	add_child(detection_area)

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if body.collision_layer & 4:  # Enemy layer
		enemies_in_range.append(body)


func _on_body_exited(body: Node3D) -> void:
	enemies_in_range.erase(body)
	if current_target == body:
		current_target = null
