# Medieval Tower Defense

A mobile tower defense game built with Godot Engine 4.x for Android.

## Features

- **Procedural Level Generation** - Every game creates a unique path layout
- **4 Tower Types** - Archer, Mage, Cannon, and Barracks
- **3 Enemy Types** - Goblins, Orcs, and Trolls with progressive difficulty
- **10 Wave Campaign** - Increasing challenge with diverse enemy compositions
- **Tower Upgrades** - 3 upgrade levels per tower with damage and range scaling
- **Touch Controls** - Optimized for mobile play

## Tower Types

| Tower | Damage | Range | Speed | Cost |
|-------|--------|-------|-------|------|
| Archer | 15 | 200 | 2.0/s | 100g |
| Mage | 35 | 180 | 0.8/s | 150g |
| Cannon | 80 | 220 | 0.5/s | 200g |
| Barracks | - | 100 | - | 120g |

## How to Play

1. Tap a tower type from the bottom panel to select it
2. Tap on a green buildable tile to place the tower
3. Tap an existing tower to upgrade it
4. Press "Start Wave" to begin enemy spawns
5. Survive all 10 waves to win

## Building from Source

### Requirements
- Godot Engine 4.2+
- Android SDK (for mobile export)
- Java JDK 17

### Running in Editor
```bash
godot --editor project.godot
```

### Android Export
1. Open project in Godot Editor
2. Go to Editor > Manage Export Templates > Download
3. Project > Export > Select "Android"
4. Configure keystore for release builds
5. Export as .apk

## Project Structure

```
medieval_tower_defense/
├── scripts/           # Core game logic (~1500 LOC)
├── scenes/            # Godot scene files
├── assets/            # Sprites and audio (placeholder)
├── project.godot      # Engine configuration
└── export_presets.cfg # Android export settings
```

## Technical Details

- **Architecture:** Signal-based event system
- **Rendering:** 2D with procedural textures (Mobile renderer)
- **Target:** Android 5.0+ (API 21), arm64-v8a
- **Package:** com.medievaltd.game

## License

All rights reserved.
