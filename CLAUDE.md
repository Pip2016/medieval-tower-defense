# CLAUDE.md — Medieval Tower Defense

This file provides guidance for AI assistants working on this codebase.

## Project Overview

Medieval Tower Defense is a browser-based tower defense game with a medieval theme. This is a new project — the repository is in its initial setup phase.

## Repository Status

This project is in early development. The repository was initialized but does not yet contain application code. Contributors (human or AI) should follow the conventions below when adding code.

## Recommended Tech Stack

Based on the project type (browser-based game), the expected stack is:

- **Language**: TypeScript
- **Build Tool**: Vite
- **Rendering**: HTML5 Canvas or a lightweight 2D game library (e.g., Phaser, PixiJS)
- **Testing**: Vitest
- **Linting**: ESLint with TypeScript support
- **Formatting**: Prettier
- **Package Manager**: npm

## Proposed Directory Structure

```
medieval-tower-defense/
├── CLAUDE.md              # This file
├── README.md              # Project readme
├── package.json
├── tsconfig.json
├── vite.config.ts
├── index.html             # Entry HTML
├── src/
│   ├── main.ts            # Application entry point
│   ├── game/
│   │   ├── Game.ts        # Main game loop and state management
│   │   ├── Map.ts         # Map/level representation
│   │   └── Wave.ts        # Enemy wave management
│   ├── entities/
│   │   ├── Tower.ts       # Base tower class
│   │   ├── Enemy.ts       # Base enemy class
│   │   └── Projectile.ts  # Projectile/bullet class
│   ├── systems/
│   │   ├── Renderer.ts    # Canvas rendering
│   │   ├── Physics.ts     # Collision detection
│   │   └── Input.ts       # User input handling
│   ├── ui/
│   │   ├── HUD.ts         # In-game HUD (health, gold, wave info)
│   │   └── Menu.ts        # Menus (start, pause, game over)
│   ├── data/
│   │   ├── towers.ts      # Tower definitions (stats, costs)
│   │   ├── enemies.ts     # Enemy definitions (stats, speed)
│   │   └── levels.ts      # Level/map definitions
│   └── utils/
│       ├── math.ts        # Vector math, distance calculations
│       └── constants.ts   # Game constants
├── assets/
│   ├── sprites/           # Tower, enemy, and environment sprites
│   ├── audio/             # Sound effects and music
│   └── maps/              # Level map data files
└── tests/
    ├── game/
    ├── entities/
    └── systems/
```

## Build & Development Commands

Once the project is scaffolded, expected commands:

| Command | Description |
|---------|-------------|
| `npm install` | Install dependencies |
| `npm run dev` | Start dev server with hot reload |
| `npm run build` | Production build |
| `npm run preview` | Preview production build locally |
| `npm run test` | Run test suite |
| `npm run test:watch` | Run tests in watch mode |
| `npm run lint` | Run ESLint |
| `npm run lint:fix` | Auto-fix lint issues |
| `npm run format` | Run Prettier |

## Coding Conventions

### TypeScript

- Use strict TypeScript (`"strict": true` in tsconfig)
- Prefer `interface` over `type` for object shapes
- Use `enum` or const objects for fixed sets of values (tower types, enemy types)
- Avoid `any` — use `unknown` with type guards when the type is truly uncertain
- Export types/interfaces from the file where they are defined

### Naming

- **Files**: PascalCase for classes (`Tower.ts`), camelCase for utilities (`math.ts`)
- **Classes**: PascalCase (`ArcherTower`, `GoblinEnemy`)
- **Functions/methods**: camelCase (`calculateDamage`, `spawnWave`)
- **Constants**: UPPER_SNAKE_CASE (`MAX_TOWERS`, `BASE_HEALTH`)
- **Interfaces**: PascalCase, no `I` prefix (`TowerConfig`, not `ITowerConfig`)

### Game Architecture

- Use a component-based or entity-system pattern where practical
- Keep game logic separate from rendering logic
- Game loop should use `requestAnimationFrame` with delta-time for frame-independent updates
- State changes should be predictable — avoid hidden side effects in update methods

### Testing

- Place tests in `tests/` mirroring the `src/` directory structure
- Name test files with `.test.ts` suffix
- Test game logic (damage calculations, pathfinding, wave spawning) independently of rendering
- Use descriptive test names: `it("should deal double damage to armored enemies when tower is upgraded")`

### Git Workflow

- Use descriptive commit messages focused on "why" not "what"
- Keep commits atomic — one logical change per commit
- Branch names follow the pattern: `claude/<description>-<sessionId>`

## Key Design Decisions

These should be documented here as they are made:

- *(No decisions recorded yet — update this section as the project evolves)*

## Common Pitfalls

- **Game loop timing**: Always use delta-time (`dt`) for movement and animations to avoid speed differences across frame rates
- **Canvas coordinate system**: Origin (0,0) is top-left; y increases downward
- **Asset loading**: Load all assets before starting the game loop; use a loading screen
- **Memory management**: Remove destroyed enemies/projectiles from arrays to prevent memory leaks in long sessions
