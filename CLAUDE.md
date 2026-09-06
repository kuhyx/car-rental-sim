# CLAUDE.md — car-rental-sim

Top-down car rental sim (pick up tourists, deliver them, take damage, buy a
better car). Godot 4 (GDScript), GL Compatibility renderer for wide hardware
support.

- Git remote: `origin` → `github.com/kuhyx/car-rental-sim`.
- No image/audio assets: every visual is a `ColorRect`/`Label`/`Button` built
  in code, so the repo stays plain text. Keep it that way unless art is
  explicitly added under a sibling `../car-rental-sim_binaries/` directory,
  per the global binary-files rule.

## Commands

- Run: `godot4 --path . 2>/dev/null || godot --path .`
- Headless syntax/parse check (no window): `godot --headless --path . --quit`
- No test framework yet — v1 is verified by playing it. If test coverage is
  added later, prefer GUT (Godot Unit Test).

## Architecture

- `project.godot` — autoloads `GameState`, fixes the window to the world size
  (960x640) so no camera is needed.
- `scripts/game_state.gd` — money, current car, damage, and the car catalog
  (`CarModel`: id/name/price/max_health/color).
- `scripts/car.gd` — `CharacterBody2D`; arrow/WASD movement, applies damage to
  `GameState` on hard collisions.
- `scripts/pickup_point.gd` / `destination_point.gd` — `Area2D` markers for
  the tourist pickup/drop-off loop.
- `scripts/garage.gd` — `Area2D` zone; `main.gd` toggles the buy-car panel
  when the car is inside it and Enter is pressed.
- `scripts/main.gd` — builds the world (walls, garage, car), spawns pickup
  points, and owns the HUD (money/damage/status labels + garage panel).

Every entity is built via a static `create()` factory instead of a `.tscn`
scene file, so adding a new entity type means one new script, not a scene +
script pair.

## Conventions

- Tabs for indentation (Godot/GDScript convention), typed GDScript
  (`var x: int`, typed function returns) throughout.
- One responsibility per script; `main.gd` orchestrates but game objects own
  their own behavior.
- Work directly on `main`, commit and push without asking (per global
  git-rules). End commits with
  `Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>`.
