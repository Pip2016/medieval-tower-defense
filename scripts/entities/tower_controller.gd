class_name TowerController
extends Node3D

## Main tower controller. Coordinates targeting, attacking, upgrades.

signal tower_upgraded(new_level: int)

@export var tower_data: TowerData

var current_level: int = 1
var grid_position: Vector2i
var targeting: TowerTargeting
var attack: TowerAttack
var body_mesh: MeshInstance3D
var range_indicator: MeshInstance3D


func _ready() -> void:
	targeting = TowerTargeting.new()
	targeting.name = "Targeting"
	add_child(targeting)

	attack = TowerAttack.new()
	attack.name = "Attack"
	add_child(attack)


func initialize(data: TowerData, grid_pos: Vector2i) -> void:
	tower_data = data
	grid_position = grid_pos
	current_level = 1

	var stats: Dictionary = tower_data.get_stats_at_level(current_level)
	targeting.initialize(stats["range"])
	attack.initialize(stats["damage"], stats["attack_speed"], tower_data.projectile_color, tower_data.projectile_speed, tower_data.projectile_size)

	_create_visuals()


func upgrade() -> bool:
	if current_level >= tower_data.max_level:
		return false

	var cost: int = tower_data.get_upgrade_cost(current_level)
	if cost < 0 or not GameState.spend_gold(cost):
		return false

	current_level += 1
	var stats: Dictionary = tower_data.get_stats_at_level(current_level)
	targeting.update_range(stats["range"])
	attack.update_stats(stats["damage"], stats["attack_speed"])

	_update_visuals()
	tower_upgraded.emit(current_level)
	GameEvents.tower_upgraded.emit(self, current_level)
	return true


func get_sell_value() -> int:
	var total_spent: int = tower_data.base_cost
	for i in range(current_level - 1):
		if i < tower_data.upgrades.size():
			total_spent += tower_data.upgrades[i].upgrade_cost
	return int(total_spent * 0.7)


func sell() -> void:
	var refund: int = get_sell_value()
	GameState.add_gold(refund)
	GameEvents.tower_sold.emit(self, refund)
	queue_free()


func show_range_indicator(visible_state: bool) -> void:
	if range_indicator:
		range_indicator.visible = visible_state


func _create_visuals() -> void:
	# Tower body
	body_mesh = MeshInstance3D.new()
	body_mesh.name = "TowerBody"

	match tower_data.tower_type:
		TowerData.TowerType.ARCHER:
			_build_archer_visual()
		TowerData.TowerType.MAGE:
			_build_mage_visual()
		TowerData.TowerType.CANNON:
			_build_cannon_visual()
		TowerData.TowerType.BARRACKS:
			_build_barracks_visual()

	# Range indicator (hidden by default)
	_create_range_indicator()


func _build_archer_visual() -> void:
	var base := CylinderMesh.new()
	base.top_radius = 0.5
	base.bottom_radius = 0.7
	base.height = 2.5
	body_mesh.mesh = base
	body_mesh.position.y = 1.25

	var mat := StandardMaterial3D.new()
	mat.albedo_color = tower_data.tower_color
	body_mesh.set_surface_override_material(0, mat)
	add_child(body_mesh)

	# Battlement top
	var top := MeshInstance3D.new()
	var top_mesh := CylinderMesh.new()
	top_mesh.top_radius = 0.6
	top_mesh.bottom_radius = 0.5
	top_mesh.height = 0.4
	top.mesh = top_mesh
	top.position.y = 2.7

	var top_mat := StandardMaterial3D.new()
	top_mat.albedo_color = tower_data.tower_color.darkened(0.2)
	top.set_surface_override_material(0, top_mat)
	add_child(top)


func _build_mage_visual() -> void:
	var base := CylinderMesh.new()
	base.top_radius = 0.4
	base.bottom_radius = 0.6
	base.height = 3.0
	body_mesh.mesh = base
	body_mesh.position.y = 1.5

	var mat := StandardMaterial3D.new()
	mat.albedo_color = tower_data.tower_color
	body_mesh.set_surface_override_material(0, mat)
	add_child(body_mesh)

	# Crystal top
	var crystal := MeshInstance3D.new()
	var crystal_mesh := SphereMesh.new()
	crystal_mesh.radius = 0.3
	crystal_mesh.height = 0.6
	crystal.mesh = crystal_mesh
	crystal.position.y = 3.2

	var crystal_mat := StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.6, 0.3, 1.0)
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(0.4, 0.2, 0.8)
	crystal_mat.emission_energy_multiplier = 2.0
	crystal.set_surface_override_material(0, crystal_mat)
	add_child(crystal)


func _build_cannon_visual() -> void:
	var base := BoxMesh.new()
	base.size = Vector3(1.4, 1.2, 1.4)
	body_mesh.mesh = base
	body_mesh.position.y = 0.6

	var mat := StandardMaterial3D.new()
	mat.albedo_color = tower_data.tower_color
	body_mesh.set_surface_override_material(0, mat)
	add_child(body_mesh)

	# Barrel
	var barrel := MeshInstance3D.new()
	var barrel_mesh := CylinderMesh.new()
	barrel_mesh.top_radius = 0.2
	barrel_mesh.bottom_radius = 0.25
	barrel_mesh.height = 1.5
	barrel.mesh = barrel_mesh
	barrel.position.y = 1.2
	barrel.position.z = 0.4
	barrel.rotation.x = -0.4

	var barrel_mat := StandardMaterial3D.new()
	barrel_mat.albedo_color = Color(0.3, 0.3, 0.3)
	barrel.set_surface_override_material(0, barrel_mat)
	add_child(barrel)


func _build_barracks_visual() -> void:
	var base := BoxMesh.new()
	base.size = Vector3(1.8, 1.0, 1.8)
	body_mesh.mesh = base
	body_mesh.position.y = 0.5

	var mat := StandardMaterial3D.new()
	mat.albedo_color = tower_data.tower_color
	body_mesh.set_surface_override_material(0, mat)
	add_child(body_mesh)

	# Roof
	var roof := MeshInstance3D.new()
	var roof_mesh := PrismMesh.new()
	roof_mesh.size = Vector3(2.0, 0.8, 2.0)
	roof.mesh = roof_mesh
	roof.position.y = 1.4

	var roof_mat := StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.5, 0.2, 0.1)
	roof.set_surface_override_material(0, roof_mat)
	add_child(roof)


func _update_visuals() -> void:
	# Add level stars
	for child in get_children():
		if child.name.begins_with("Star"):
			child.queue_free()

	for i in range(current_level - 1):
		var star := MeshInstance3D.new()
		star.name = "Star_%d" % i
		var star_mesh := SphereMesh.new()
		star_mesh.radius = 0.1
		star_mesh.height = 0.2
		star.mesh = star_mesh
		star.position = Vector3(-0.3 + i * 0.3, 0.1, -0.8)

		var star_mat := StandardMaterial3D.new()
		star_mat.albedo_color = Color(1.0, 0.9, 0.0)
		star_mat.emission_enabled = true
		star_mat.emission = Color(1.0, 0.8, 0.0)
		star.set_surface_override_material(0, star_mat)
		add_child(star)


func _create_range_indicator() -> void:
	range_indicator = MeshInstance3D.new()
	range_indicator.name = "RangeIndicator"
	var stats: Dictionary = tower_data.get_stats_at_level(current_level)
	var ring := CylinderMesh.new()
	ring.top_radius = stats["range"]
	ring.bottom_radius = stats["range"]
	ring.height = 0.02
	range_indicator.mesh = ring
	range_indicator.position.y = 0.05

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1, 1, 1, 0.15)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	range_indicator.set_surface_override_material(0, mat)
	range_indicator.visible = false
	add_child(range_indicator)
