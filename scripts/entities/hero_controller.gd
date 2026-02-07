class_name HeroController
extends Node3D

## Hero controller with ability casting system.

@export var abilities: Array[AbilityData] = []

var ability_system: AbilitySystem
var cooldowns: Array[float] = []


func _ready() -> void:
	ability_system = AbilitySystem.new()
	ability_system.name = "AbilitySystem"
	add_child(ability_system)

	cooldowns.resize(abilities.size())
	cooldowns.fill(0.0)


func _process(_delta: float) -> void:
	# Check input for ability keys
	for i in range(mini(abilities.size(), 4)):
		var action: String = "ability_%d" % (i + 1)
		if Input.is_action_just_pressed(action):
			cast_ability(i)


func cast_ability(index: int) -> void:
	if index < 0 or index >= abilities.size():
		return

	var ability: AbilityData = abilities[index]
	if ability_system.is_ready(index):
		# Get target position from mouse/touch
		var target_pos: Vector3 = _get_target_position()
		ability_system.cast(ability, index, target_pos)
		GameEvents.ability_cast.emit(index, target_pos)


func _get_target_position() -> Vector3:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return Vector3.ZERO

	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var dir: Vector3 = camera.project_ray_normal(mouse_pos)

	# Intersect with ground plane (y=0)
	if abs(dir.y) > 0.001:
		var t: float = -from.y / dir.y
		if t > 0:
			return from + dir * t

	return Vector3.ZERO
