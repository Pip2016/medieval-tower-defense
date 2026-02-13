class_name WaypointPath
extends Resource

## Defines a path enemies follow, with interpolation support.

enum InterpolationType { LINEAR, BEZIER, CATMULL_ROM }

@export var waypoints: Array[Vector3] = []
@export var interpolation: InterpolationType = InterpolationType.LINEAR


func get_total_length() -> float:
	var length: float = 0.0
	for i in range(waypoints.size() - 1):
		length += waypoints[i].distance_to(waypoints[i + 1])
	return length


func get_point_at_distance(dist: float) -> Vector3:
	if waypoints.is_empty():
		return Vector3.ZERO
	if waypoints.size() == 1:
		return waypoints[0]

	var accumulated: float = 0.0
	for i in range(waypoints.size() - 1):
		var segment_length: float = waypoints[i].distance_to(waypoints[i + 1])
		if accumulated + segment_length >= dist:
			var t: float = (dist - accumulated) / segment_length if segment_length > 0 else 0.0
			match interpolation:
				InterpolationType.LINEAR:
					return waypoints[i].lerp(waypoints[i + 1], t)
				InterpolationType.CATMULL_ROM:
					return _catmull_rom(i, t)
				_:
					return waypoints[i].lerp(waypoints[i + 1], t)
		accumulated += segment_length

	return waypoints[waypoints.size() - 1]


func get_direction_at_distance(dist: float) -> Vector3:
	var delta: float = 0.1
	var p1: Vector3 = get_point_at_distance(dist)
	var p2: Vector3 = get_point_at_distance(dist + delta)
	return (p2 - p1).normalized()


func _catmull_rom(segment_index: int, t: float) -> Vector3:
	var p0: Vector3 = waypoints[maxi(segment_index - 1, 0)]
	var p1: Vector3 = waypoints[segment_index]
	var p2: Vector3 = waypoints[mini(segment_index + 1, waypoints.size() - 1)]
	var p3: Vector3 = waypoints[mini(segment_index + 2, waypoints.size() - 1)]

	var t2: float = t * t
	var t3: float = t2 * t

	return 0.5 * (
		(2.0 * p1) +
		(-p0 + p2) * t +
		(2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 +
		(-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3
	)
