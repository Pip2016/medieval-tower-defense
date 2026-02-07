# Tower Defense - Enterprise Edition

A professional tower defense game built with Godot 4.2+ using resource-based data-driven architecture.

## Architecture

```
Data Layer (Resources) → Game Systems (Managers) → Entities (Towers/Enemies) → Presentation (3D/UI)
```

**Design Pattern:** Resource-Based Data-Driven, ECS-Inspired
**Rendering:** 3D with Forward+ (Desktop) / Mobile renderer
**Platforms:** PC, Mobile (Android/iOS), Console

## Features

- **Resource-Driven Data** - All game entities defined via extensible Resource types
- **4 Tower Types** with 3 upgrade levels each (Archer, Mage, Cannon, Barracks)
- **4 Enemy Types** with stat scaling (Goblin, Orc, Troll, Dragon Boss)
- **15 Wave Campaign** with progressive difficulty and boss waves
- **Hero Ability System** - 4 abilities (Fireball, Frost Nova, Lightning, Rally)
- **RTS Camera** - Pan, zoom, rotation controls
- **Signal-Based Architecture** - Type-safe global event bus
- **Status Effects** - Slow, stun, DOT, buffs
- **Tower Management** - Build, upgrade, sell with full economy

## Project Structure

```
res://
├── data/                    # Resources (.tres files)
│   ├── towers/enemies/waves/abilities/
├── scripts/
│   ├── autoload/           # GameEvents, GameState singletons
│   ├── core/               # Resource classes (TowerData, EnemyData, etc.)
│   ├── systems/            # GridManager, WaveManager, GameCamera, GameLevel
│   ├── entities/           # TowerController, EnemyController, HeroController
│   └── ui/                 # GameHUD, MainMenu
├── scenes/main/            # MainMenu.tscn, GameLevel.tscn
└── assets/                 # Models, textures, materials, particles
```

## Tower Types

| Tower | Damage | Range | Speed | Cost |
|-------|--------|-------|-------|------|
| Archer | 15 | 8.0 | 2.0/s | 100g |
| Mage | 35 | 7.0 | 0.8/s | 150g |
| Cannon | 80 | 10.0 | 0.5/s | 200g |
| Barracks | - | 5.0 | - | 120g |

## Enemy Types

| Enemy | HP | Speed | Reward | Type |
|-------|-----|-------|--------|------|
| Goblin | 60 | 4.0 | 8g | Ground |
| Orc | 180 | 2.5 | 18g | Armored |
| Troll | 500 | 1.5 | 35g | Armored |
| Dragon | 2000 | 1.0 | 100g | Boss |

## Hero Abilities

| Ability | Cooldown | Effect |
|---------|----------|--------|
| Fireball | 12s | 80 fire damage, 4.0 AoE |
| Frost Nova | 15s | Slow 50% for 4s, 6.0 AoE |
| Lightning | 20s | 150 damage + 3s stun |
| Rally | 45s | Restore 5 lives |

## Controls

- **Left Click** - Place tower / Select tower
- **Middle Mouse** - Pan camera
- **Scroll** - Zoom in/out
- **1-4** - Cast abilities
- **Escape** - Cancel / Deselect

## Building from Source

### Requirements
- Godot Engine 4.2+
- Android SDK (for mobile export)
- Java JDK 17 (for Android)

### Run in Editor
```bash
godot --editor project.godot
# Press F5 to run
```

### Export
Pre-configured exports for: Windows, Linux, Android, iOS (see `export_presets.cfg`)

## Technical Highlights

- **Zero external dependencies** - Pure Godot 4
- **~2500 LOC** across 22 script files
- **Type-safe signals** via global event bus
- **Resource inheritance** for data-driven design
- **Status effect system** with slow/stun/DOT
- **Target priority system** (First, Last, Strongest, Weakest, Closest)
- **Catmull-Rom path interpolation** support
