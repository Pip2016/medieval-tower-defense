extends Node3D

## Main game level controller. Orchestrates all systems: grid, waves, towers, hero, UI.

# Systems
var grid_manager: GridManager
var wave_manager: WaveManager
var hero_controller: HeroController
var game_camera: GameCamera
var hud: GameHUD

# Containers
var enemy_container: Node3D
var tower_container: Node3D
var environment_node: Node3D

# State
var selected_tower_data: TowerData
var selected_tower_instance: TowerController
var is_build_mode: bool = false

# Tower data resources (loaded at runtime)
var tower_datas: Array[TowerData] = []
var enemy_datas: Array[EnemyData] = []
var ability_datas: Array[AbilityData] = []

# Default enemy path
var default_path: WaypointPath


func _ready() -> void:
	_create_data_resources()
	_setup_environment()
	_setup_containers()
	_setup_systems()
	_setup_path()
	_connect_signals()

	# Initialize grid with path
	grid_manager.setup_path(default_path.waypoints)

	# Setup wave spawner
	wave_manager.spawner.setup(
		default_path.waypoints[0] if not default_path.waypoints.is_empty() else Vector3.ZERO,
		default_path,
		enemy_container
	)

	# Set tower data in HUD
	hud.set_tower_datas(tower_datas)


func _create_data_resources() -> void:
	# Archer tower
	var archer := TowerData.new()
	archer.tower_name = "Archer Tower"
	archer.tower_type = TowerData.TowerType.ARCHER
	archer.description = "Fast-firing tower with moderate range."
	archer.base_cost = 100
	archer.base_range = 8.0
	archer.base_damage = 15.0
	archer.base_attack_speed = 2.0
	archer.tower_color = Color(0.2, 0.55, 0.2)
	archer.projectile_color = Color(0.8, 0.6, 0.2)
	archer.projectile_speed = 25.0
	archer.projectile_size = 0.1
	archer.max_level = 3
	var archer_up1 := TowerUpgradeData.new()
	archer_up1.upgrade_name = "Sharp Arrows"
	archer_up1.upgrade_cost = 80
	archer_up1.damage_multiplier = 1.5
	archer_up1.range_multiplier = 1.1
	var archer_up2 := TowerUpgradeData.new()
	archer_up2.upgrade_name = "Longbow"
	archer_up2.upgrade_cost = 150
	archer_up2.damage_multiplier = 1.5
	archer_up2.range_multiplier = 1.15
	archer.upgrades = [archer_up1, archer_up2]
	tower_datas.append(archer)

	# Mage tower
	var mage := TowerData.new()
	mage.tower_name = "Mage Tower"
	mage.tower_type = TowerData.TowerType.MAGE
	mage.description = "High damage magic attacks. Bypasses armor."
	mage.base_cost = 150
	mage.base_range = 7.0
	mage.base_damage = 35.0
	mage.base_attack_speed = 0.8
	mage.tower_color = Color(0.35, 0.2, 0.65)
	mage.projectile_color = Color(0.6, 0.3, 1.0)
	mage.projectile_speed = 18.0
	mage.projectile_size = 0.18
	mage.max_level = 3
	var mage_up1 := TowerUpgradeData.new()
	mage_up1.upgrade_name = "Arcane Mastery"
	mage_up1.upgrade_cost = 120
	mage_up1.damage_multiplier = 1.6
	var mage_up2 := TowerUpgradeData.new()
	mage_up2.upgrade_name = "Spell Surge"
	mage_up2.upgrade_cost = 220
	mage_up2.damage_multiplier = 1.5
	mage_up2.speed_multiplier = 1.3
	mage.upgrades = [mage_up1, mage_up2]
	tower_datas.append(mage)

	# Cannon tower
	var cannon := TowerData.new()
	cannon.tower_name = "Cannon"
	cannon.tower_type = TowerData.TowerType.CANNON
	cannon.description = "Slow but devastating. Great range."
	cannon.base_cost = 200
	cannon.base_range = 10.0
	cannon.base_damage = 80.0
	cannon.base_attack_speed = 0.5
	cannon.tower_color = Color(0.45, 0.45, 0.45)
	cannon.projectile_color = Color(0.2, 0.2, 0.2)
	cannon.projectile_speed = 15.0
	cannon.projectile_size = 0.2
	cannon.max_level = 3
	var cannon_up1 := TowerUpgradeData.new()
	cannon_up1.upgrade_name = "Heavy Shells"
	cannon_up1.upgrade_cost = 160
	cannon_up1.damage_multiplier = 1.5
	cannon_up1.range_multiplier = 1.1
	var cannon_up2 := TowerUpgradeData.new()
	cannon_up2.upgrade_name = "Siege Cannon"
	cannon_up2.upgrade_cost = 300
	cannon_up2.damage_multiplier = 1.6
	cannon.upgrades = [cannon_up1, cannon_up2]
	tower_datas.append(cannon)

	# Barracks tower
	var barracks := TowerData.new()
	barracks.tower_name = "Barracks"
	barracks.tower_type = TowerData.TowerType.BARRACKS
	barracks.description = "Spawns soldiers to block enemies."
	barracks.base_cost = 120
	barracks.base_range = 5.0
	barracks.base_damage = 0.0
	barracks.base_attack_speed = 0.0
	barracks.tower_color = Color(0.6, 0.45, 0.2)
	barracks.max_level = 3
	var barracks_up1 := TowerUpgradeData.new()
	barracks_up1.upgrade_name = "Veterans"
	barracks_up1.upgrade_cost = 100
	var barracks_up2 := TowerUpgradeData.new()
	barracks_up2.upgrade_name = "Elite Guards"
	barracks_up2.upgrade_cost = 200
	barracks.upgrades = [barracks_up1, barracks_up2]
	tower_datas.append(barracks)

	# Enemy data
	var goblin := EnemyData.new()
	goblin.enemy_name = "Goblin"
	goblin.enemy_type = EnemyData.EnemyType.GROUND
	goblin.base_health = 60.0
	goblin.base_speed = 4.0
	goblin.gold_reward = 8
	goblin.lives_cost = 1
	goblin.body_color = Color(0.2, 0.7, 0.15)
	goblin.body_scale = 0.8
	enemy_datas.append(goblin)

	var orc := EnemyData.new()
	orc.enemy_name = "Orc"
	orc.enemy_type = EnemyData.EnemyType.ARMORED
	orc.base_health = 180.0
	orc.base_speed = 2.5
	orc.gold_reward = 18
	orc.lives_cost = 2
	orc.base_armor = 5.0
	orc.physical_resistance = 0.2
	orc.body_color = Color(0.5, 0.35, 0.15)
	orc.body_scale = 1.2
	enemy_datas.append(orc)

	var troll := EnemyData.new()
	troll.enemy_name = "Troll"
	troll.enemy_type = EnemyData.EnemyType.ARMORED
	troll.base_health = 500.0
	troll.base_speed = 1.5
	troll.gold_reward = 35
	troll.lives_cost = 5
	troll.base_armor = 10.0
	troll.physical_resistance = 0.3
	troll.magic_resistance = 0.1
	troll.body_color = Color(0.45, 0.1, 0.45)
	troll.body_scale = 1.6
	enemy_datas.append(troll)

	var dragon := EnemyData.new()
	dragon.enemy_name = "Dragon"
	dragon.enemy_type = EnemyData.EnemyType.BOSS
	dragon.base_health = 2000.0
	dragon.base_speed = 1.0
	dragon.gold_reward = 100
	dragon.lives_cost = 10
	dragon.base_armor = 20.0
	dragon.physical_resistance = 0.3
	dragon.magic_resistance = 0.3
	dragon.fire_resistance = 0.8
	dragon.body_color = Color(0.8, 0.15, 0.1)
	dragon.body_scale = 2.0
	enemy_datas.append(dragon)

	# Abilities
	var fireball := AbilityData.new()
	fireball.ability_name = "Fireball"
	fireball.description = "Deals fire damage in an area."
	fireball.cooldown = 12.0
	fireball.ability_range = 50.0
	fireball.damage = 80.0
	fireball.damage_type = AbilityData.DamageType.FIRE
	fireball.area_of_effect = 4.0
	fireball.target_type = AbilityData.AbilityTargetType.POINT
	fireball.effect_color = Color(1.0, 0.4, 0.1)
	fireball.effect_duration = 0.6
	ability_datas.append(fireball)

	var frost_nova := AbilityData.new()
	frost_nova.ability_name = "Frost Nova"
	frost_nova.description = "Slows all enemies in an area."
	frost_nova.cooldown = 15.0
	frost_nova.ability_range = 50.0
	frost_nova.damage = 20.0
	frost_nova.damage_type = AbilityData.DamageType.MAGIC
	frost_nova.area_of_effect = 6.0
	frost_nova.target_type = AbilityData.AbilityTargetType.POINT
	frost_nova.effect_color = Color(0.3, 0.7, 1.0)
	frost_nova.effect_duration = 0.8
	var slow_effect := AbilityEffect.new()
	slow_effect.effect_type = AbilityEffect.EffectType.SLOW
	slow_effect.value = 0.5
	slow_effect.duration = 4.0
	frost_nova.effects = [slow_effect]
	ability_datas.append(frost_nova)

	var lightning := AbilityData.new()
	lightning.ability_name = "Lightning"
	lightning.description = "Stuns and damages a single target."
	lightning.cooldown = 20.0
	lightning.ability_range = 50.0
	lightning.damage = 150.0
	lightning.damage_type = AbilityData.DamageType.MAGIC
	lightning.target_type = AbilityData.AbilityTargetType.ENEMY
	lightning.effect_color = Color(1.0, 1.0, 0.3)
	lightning.effect_duration = 0.3
	var stun_effect := AbilityEffect.new()
	stun_effect.effect_type = AbilityEffect.EffectType.STUN
	stun_effect.duration = 3.0
	lightning.effects = [stun_effect]
	ability_datas.append(lightning)

	var heal := AbilityData.new()
	heal.ability_name = "Rally"
	heal.description = "Restores 5 lives."
	heal.cooldown = 45.0
	heal.ability_range = 0.0
	heal.damage = 0.0
	heal.target_type = AbilityData.AbilityTargetType.SELF
	heal.effect_color = Color(0.2, 1.0, 0.4)
	heal.effect_duration = 1.0
	var heal_effect := AbilityEffect.new()
	heal_effect.effect_type = AbilityEffect.EffectType.HEAL
	heal_effect.value = 5.0
	heal.effects = [heal_effect]
	ability_datas.append(heal)

	# Create waves
	_create_waves()


func _create_waves() -> void:
	for i in range(GameState.MAX_WAVES):
		var wave := WaveData.new()
		wave.wave_number = i + 1
		wave.completion_gold = 50 + (i * 15)
		wave.is_boss_wave = (i + 1) % 5 == 0

		if i < 3:
			# Early waves: goblins only
			var spawn := EnemySpawnData.new()
			spawn.enemy_data = enemy_datas[0]  # Goblin
			spawn.count = 5 + i * 3
			spawn.spawn_interval = maxf(0.5, 1.2 - i * 0.1)
			wave.enemy_spawns = [spawn]
		elif i < 6:
			# Mid waves: goblins + orcs
			var spawn1 := EnemySpawnData.new()
			spawn1.enemy_data = enemy_datas[0]  # Goblin
			spawn1.count = 4 + i
			spawn1.spawn_interval = 0.8
			var spawn2 := EnemySpawnData.new()
			spawn2.enemy_data = enemy_datas[1]  # Orc
			spawn2.count = 2 + i - 3
			spawn2.spawn_interval = 1.2
			spawn2.start_delay = 3.0
			wave.enemy_spawns = [spawn1, spawn2]
		elif i < 10:
			# Late waves: mixed
			var spawn1 := EnemySpawnData.new()
			spawn1.enemy_data = enemy_datas[0]
			spawn1.count = 6 + i
			spawn1.spawn_interval = 0.6
			var spawn2 := EnemySpawnData.new()
			spawn2.enemy_data = enemy_datas[1]
			spawn2.count = 4 + i - 5
			spawn2.spawn_interval = 1.0
			spawn2.start_delay = 2.0
			var spawn3 := EnemySpawnData.new()
			spawn3.enemy_data = enemy_datas[2]  # Troll
			spawn3.count = 1 + (i - 6)
			spawn3.spawn_interval = 2.0
			spawn3.start_delay = 6.0
			wave.enemy_spawns = [spawn1, spawn2, spawn3]
		else:
			# Final waves: everything + bosses
			var spawn1 := EnemySpawnData.new()
			spawn1.enemy_data = enemy_datas[1]
			spawn1.count = 8 + i - 8
			spawn1.spawn_interval = 0.5
			var spawn2 := EnemySpawnData.new()
			spawn2.enemy_data = enemy_datas[2]
			spawn2.count = 3 + i - 9
			spawn2.spawn_interval = 1.5
			spawn2.start_delay = 4.0
			wave.enemy_spawns = [spawn1, spawn2]

			if wave.is_boss_wave:
				var boss_spawn := EnemySpawnData.new()
				boss_spawn.enemy_data = enemy_datas[3]  # Dragon
				boss_spawn.count = 1
				boss_spawn.spawn_interval = 0.0
				boss_spawn.start_delay = 10.0
				wave.enemy_spawns.append(boss_spawn)

		wave_manager.waves.append(wave)


func _setup_environment() -> void:
	environment_node = Node3D.new()
	environment_node.name = "Environment"
	add_child(environment_node)

	# Ground plane
	var ground := MeshInstance3D.new()
	ground.name = "Ground"
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(grid_manager.grid_size.x if grid_manager else 20, grid_manager.grid_size.y if grid_manager else 15) * 2.0
	ground.mesh = ground_mesh
	var ground_mat := StandardMaterial3D.new()
	ground_mat.albedo_color = Color(0.25, 0.35, 0.15)
	ground.set_surface_override_material(0, ground_mat)
	ground.position = Vector3(20, -0.01, 15)
	environment_node.add_child(ground)

	# Directional light
	var light := DirectionalLight3D.new()
	light.name = "Sun"
	light.rotation = Vector3(-0.9, 0.4, 0)
	light.light_energy = 1.2
	light.shadow_enabled = true
	environment_node.add_child(light)

	# Ambient light via WorldEnvironment
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.4, 0.55, 0.7)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.5, 0.5, 0.6)
	env.ambient_light_energy = 0.4
	env.tonemap_mode = Environment.TONE_MAP_FILMIC
	world_env.environment = env
	environment_node.add_child(world_env)


func _setup_containers() -> void:
	enemy_container = Node3D.new()
	enemy_container.name = "EnemyContainer"
	add_child(enemy_container)

	tower_container = Node3D.new()
	tower_container.name = "TowerContainer"
	add_child(tower_container)


func _setup_systems() -> void:
	# Grid
	grid_manager = GridManager.new()
	grid_manager.name = "GridManager"
	add_child(grid_manager)

	# Waves
	wave_manager = WaveManager.new()
	wave_manager.name = "WaveManager"
	add_child(wave_manager)

	# Camera
	game_camera = GameCamera.new()
	game_camera.name = "GameCamera"
	add_child(game_camera)

	# Hero
	hero_controller = HeroController.new()
	hero_controller.name = "HeroController"
	add_child(hero_controller)

	# HUD
	hud = GameHUD.new()
	hud.name = "GameHUD"
	add_child(hud)


func _setup_path() -> void:
	default_path = WaypointPath.new()
	default_path.interpolation = WaypointPath.InterpolationType.LINEAR
	default_path.waypoints = [
		Vector3(0, 0, 15),
		Vector3(8, 0, 15),
		Vector3(8, 0, 5),
		Vector3(16, 0, 5),
		Vector3(16, 0, 25),
		Vector3(24, 0, 25),
		Vector3(24, 0, 10),
		Vector3(32, 0, 10),
		Vector3(32, 0, 20),
		Vector3(40, 0, 20),
	]

	# Set hero abilities
	hero_controller.abilities = ability_datas


func _connect_signals() -> void:
	hud.tower_build_selected.connect(_on_tower_build_selected)
	hud.tower_build_cancelled.connect(_on_tower_build_cancelled)
	hud.start_wave_pressed.connect(_on_start_wave)
	hud.restart_pressed.connect(_on_restart)
	hud.upgrade_pressed.connect(_on_upgrade_pressed)
	hud.sell_pressed.connect(_on_sell_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if GameState.is_game_over or GameState.is_game_won:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_handle_click(event.position)

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if is_build_mode:
			_on_tower_build_cancelled()
		else:
			GameEvents.tower_deselected.emit()
			selected_tower_instance = null


func _handle_click(screen_pos: Vector2) -> void:
	var world_pos: Vector3 = game_camera.get_ground_position(screen_pos)
	var grid_pos: Vector2i = grid_manager.world_to_grid(world_pos)

	if is_build_mode and selected_tower_data:
		_try_place_tower(grid_pos)
	else:
		# Check if clicking on existing tower
		var existing: Node3D = grid_manager.get_object_at(grid_pos)
		if existing and existing is TowerController:
			selected_tower_instance = existing as TowerController
			selected_tower_instance.show_range_indicator(true)
			GameEvents.tower_selected.emit(existing)
		else:
			if selected_tower_instance:
				selected_tower_instance.show_range_indicator(false)
			selected_tower_instance = null
			GameEvents.tower_deselected.emit()


func _try_place_tower(grid_pos: Vector2i) -> void:
	if not grid_manager.can_place_at(grid_pos):
		return
	if not GameState.spend_gold(selected_tower_data.base_cost):
		return

	var tower := TowerController.new()
	tower_container.add_child(tower)
	tower.initialize(selected_tower_data, grid_pos)
	tower.position = grid_manager.grid_to_world(grid_pos)

	grid_manager.occupy_cells(grid_pos, tower)
	GameEvents.tower_placed.emit(tower, grid_pos)


func _on_tower_build_selected(data: TowerData) -> void:
	selected_tower_data = data
	is_build_mode = true
	GameEvents.build_mode_entered.emit(data.tower_type)


func _on_tower_build_cancelled() -> void:
	selected_tower_data = null
	is_build_mode = false
	grid_manager.hide_hover()
	GameEvents.build_mode_exited.emit()


func _on_start_wave() -> void:
	wave_manager.start_next_wave()


func _on_restart() -> void:
	GameEvents.game_restarted.emit()
	get_tree().reload_current_scene()


func _on_upgrade_pressed() -> void:
	if selected_tower_instance:
		selected_tower_instance.upgrade()
		hud.show_tower_info(selected_tower_instance)


func _on_sell_pressed() -> void:
	if selected_tower_instance:
		grid_manager.free_cells(selected_tower_instance.grid_position)
		selected_tower_instance.sell()
		selected_tower_instance = null
		GameEvents.tower_deselected.emit()
