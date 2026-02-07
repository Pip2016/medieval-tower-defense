class_name PathFollower
extends Node

## Moves the parent node along a WaypointPath at a given speed.

signal path_completed

var path: WaypointPath
var speed: float = 50.0
var current_distance: float = 0.0
var total_length: float = 0.0
var is_active: bool = false
var body: Node3D


func _ready() -> void:
	body = get_parent() as Node3D


func setup(waypoint_path: WaypointPath, move_speed: float) -> void:
	path = waypoint_path
	speed = move_speed
	current_distance = 0.0
	total_length = path.get_total_length()
	is_active = true


func _process(delta: float) -> void:
	if not is_active or path == null or body == null:
		return

	# Check for stun via health component
	var health: EnemyHealth = null
	if body.has_node("EnemyHealth"):
		health = body.get_node("EnemyHealth") as EnemyHealth

	var current_speed: float = speed
	if health:
		if health.is_stunned:
			return
		current_speed *= health.speed_modifier

	current_distance += current_speed * delta

	if current_distance >= total_length:
		is_active = false
		path_completed.emit()
		return

	var new_pos: Vector3 = path.get_point_at_distance(current_distance)
	var direction: Vector3 = path.get_direction_at_distance(current_distance)

	body.global_position = new_pos
	if direction.length_squared() > 0.001:
		body.look_at(body.global_position + direction, Vector3.UP)


func get_progress() -> float:
	return current_distance / total_length if total_length > 0 else 0.0
