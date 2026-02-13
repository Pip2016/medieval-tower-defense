extends Node

## Global event bus singleton. Type-safe signals for decoupled communication.

# Tower events
signal tower_placed(tower: Node3D, grid_pos: Vector2i)
signal tower_upgraded(tower: Node3D, new_level: int)
signal tower_sold(tower: Node3D, refund: int)
signal tower_selected(tower: Node3D)
signal tower_deselected()

# Enemy events
signal enemy_spawned(enemy: Node3D)
signal enemy_damaged(enemy: Node3D, damage: float, remaining_hp: float)
signal enemy_killed(enemy: Node3D, gold_reward: int)
signal enemy_reached_end(enemy: Node3D, lives_cost: int)

# Wave events
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int, bonus_gold: int)
signal all_waves_completed()
signal wave_enemies_remaining(count: int)

# Game state events
signal gold_changed(new_amount: int)
signal lives_changed(new_amount: int)
signal game_over()
signal game_won()
signal game_paused(paused: bool)
signal game_restarted()

# Hero events
signal ability_cast(ability_index: int, target_pos: Vector3)
signal ability_cooldown_updated(ability_index: int, remaining: float, total: float)
signal ability_ready(ability_index: int)

# UI events
signal build_mode_entered(tower_type: TowerData.TowerType)
signal build_mode_exited()
signal upgrade_requested(grid_pos: Vector2i)
signal sell_requested(grid_pos: Vector2i)
