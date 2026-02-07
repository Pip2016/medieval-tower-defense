class_name GameCamera
extends Camera3D

## RTS-style camera with pan, zoom, and rotation.

@export var pan_speed: float = 20.0
@export var zoom_speed: float = 2.0
@export var min_zoom: float = 8.0
@export var max_zoom: float = 30.0
@export var rotation_speed: float = 2.0

var _is_panning: bool = false
var _last_mouse_pos: Vector2
var _target_position: Vector3
var _target_zoom: float = 15.0
var _camera_angle: float = -1.1  # ~63 degrees


func _ready() -> void:
	_target_position = Vector3(20, 0, 15)
	_target_zoom = 15.0
	_update_camera_transform()


func _input(event: InputEvent) -> void:
	# Pan with middle mouse
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			_is_panning = event.pressed
			_last_mouse_pos = event.position

	if event is InputEventMouseMotion and _is_panning:
		var delta: Vector2 = event.position - _last_mouse_pos
		_last_mouse_pos = event.position
		var pan := Vector3(-delta.x, 0, -delta.y) * pan_speed * 0.005
		_target_position += pan

	# Zoom with scroll
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_zoom = maxf(_target_zoom - zoom_speed, min_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_zoom = minf(_target_zoom + zoom_speed, max_zoom)

	# Touch support
	if event is InputEventScreenDrag:
		var pan := Vector3(-event.relative.x, 0, -event.relative.y) * pan_speed * 0.005
		_target_position += pan

	if event is InputEventMagnifyGesture:
		_target_zoom = clampf(_target_zoom / event.factor, min_zoom, max_zoom)


func _process(delta: float) -> void:
	_update_camera_transform()


func _update_camera_transform() -> void:
	var offset := Vector3(0, _target_zoom * sin(-_camera_angle), _target_zoom * cos(-_camera_angle))
	position = position.lerp(_target_position + offset, 0.1)
	rotation.x = _camera_angle
	rotation.y = 0


func get_ground_position(screen_pos: Vector2) -> Vector3:
	var from: Vector3 = project_ray_origin(screen_pos)
	var dir: Vector3 = project_ray_normal(screen_pos)

	if abs(dir.y) > 0.001:
		var t: float = -from.y / dir.y
		if t > 0:
			return from + dir * t

	return Vector3.ZERO
