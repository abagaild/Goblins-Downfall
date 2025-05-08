# Goblin's Downfall

A tight, narrative-driven RPG where you play as a humble Gremlin farmer whose world is shattered when the Harmony Crystal breaks, unleashing four "Goblin" bosses—embodiments of severe mental-health struggles.

## Game Concept

A hybrid lane-defense & ACT-meets-bullet-hell game built in Godot 4.4.

Core Concept: Sow Hope Seeds on your farm to grow coping-strategy plants, then defend your farm from Goblins (mental-illness manifestations) across themed biomes. Face boss duels combining Plants vs. Zombies–style lanes with Persona/Undertale‑inspired ACT & bullet-hell mechanics.

## Game Structure

- **Farm Hub**: Plant Hope Seeds → harvest Upgrade Points and materials → unlock or deepen ACT skills, bullet-hell aids, or farm boosters.
- **Exploration & Combat**: At night, protect your farm from waves of Goblins and face off against their leader in real-time bullet hell combat.
- **Shard Recovery**: Defeat the boss ("Shard Break") → reclaim a Harmony Crystal fragment and earn a new Hope Seed for your next run.

## Project Structure

- `/scenes` - Game scenes
  - `/player` - Player-related scenes
  - `/enemies` - Enemy scenes
  - `/ui` - UI elements
  - `/levels` - Game levels and areas
- `/scripts` - GDScript files
- `/assets` - Game assets
  - `/sprites` - 2D sprites
  - `/audio` - Sound effects and music
  - `/fonts` - Game fonts
- `/resources` - Resource files

## Development Roadmap

### Phase 1 – Project Setup & Core Architecture

- Initialize Godot Project
  - Create new Godot 4.4 project; configure version control
  - Establish folder structure: autoload/, scenes/, scripts/, resources/, shaders/, audio/

- Global Singletons
  - Build GlobalSignals.gd and GameState.gd as autoloads
  - Implement InputHandler.gd to map high-level actions (move, select, pause)

- Scene Management
  - Create SceneManager.gd for loading/unloading scenes with fade transitions
  - Test by swapping between two placeholder scenes

### Phase 2 – Player & Camera Controllers

- PlayerController
  - Create CharacterBody2D/3D node with movement, collision, and mode switching (exploration vs. combat)

- CameraController
  - Attach smooth-follow camera with configurable zoom (farm vs. defense) and shake effect

### Phase 3 – Farm Hub Basics

- FarmScene Layout
  - Design a 3×3 grid of soil plots; implement clickable planting

- Hope Seed & Growth Timer
  - Define Seed resource (growth time, yield range)
  - On planting, start countdown; mark harvestable on expiry

- Harvest Logic
  - Grant Sun (resource) and Upgrade Points to GameState on harvest
  - Display yield popups

### Phase 4 – Lane-Defense Framework

- DefenseScene & Grid
  - Build lanes with grid cells for plant placement; render background and farm gate

- Sun Resource System
  - Display Sun counter in HUD; allow collection of floating Sun icons

- Plant Placement
  - Spend Sun to place turrets in grid; block placement in occupied cells

### Phase 5 – Define & Implement Plants (ACT Skills)

- Plant Base Class
  - Script Plant.gd with health, attack rate, and abstract fire() method

- Specific Plants
  - Implement GroundingSprout, MindfulnessMoss, etc., wiring unique effects

- Plant Upgrades
  - Create upgrade UI to spend Upgrade Points on plant stats/tier

### Phase 6 – Enemy Waves & Minor Goblins

- Minor Goblin Scenes
  - Design Goblin enemies with lane-walking and health

- EnemySpawner
  - Script wave data loader (waves.json) and spawn logic

- Collision & Damage
  - Connect plant attacks to Goblin damage; Goblins reaching gate harm player

### Phase 7 – Boss Integration & Duel Mode

- BossController Base
  - Define boss script with phase sequence and patterns

- Siege Phase
  - Boss marches down central lane, trampling plants

- Duel Transition
  - Switch to duel arena for ACT + bullet-hell when boss hits gate

- Return to Defense
  - After duel, pause boss in lane and resume defense

### Phase 8 – Bullet-Hell & ACT System

- BulletPatternPlayer
  - Load and spawn projectile patterns from JSON or code

- ACTMenuUI
  - Build duel UI for selecting ACT skills

- ACT Skill Effects
  - Wire each ACT to boss state/battlefield modifications

- Balance Gauge & Shatter
  - Implement gauge fill on dodges/ACT success; enable "Shard Break" to stun boss

### Phase 9 – UI, Audio & VFX Polish

- HUD & Menus
  - Finalize HUD (Sun, HP, gauge), pause/settings, and transitions

- AudioManager
  - Integrate biome music, SFX for plant/harvest/shatter events

- ShaderLibrary & Particles
  - Add visual shaders (mirror distort, color shifts) and particle effects

### Phase 10 – Persistence, Meta-Progression & Balancing

- SaveLoadSystem
  - Serialize GameState to disk; auto-save at milestones

- Meta-Upgrades
  - Implement permanent increases (plots, base yield, seed drop chance)

- Balancing Pass
  - Tweak timings, costs, cooldowns, patterns for 1–2hr experience

- Final QA & Demo Build
  - Test edge cases; polish UX; compile playable demo for distribution

