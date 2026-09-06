# CLAUDE.md — car-rental-sim

Top-down car rental sim (pick up tourists, deliver them, take damage, repair
or buy a better car). Godot 4 (GDScript), GL Compatibility renderer for wide
hardware support.

- Git remote: `origin` → `github.com/kuhyx/car-rental-sim`.
- No image/audio assets: every visual is `_draw()` primitives or a themed
  `Label`/`Button`, so the repo stays plain text. Keep it that way unless art
  is explicitly added under a sibling `../car-rental-sim_binaries/` directory,
  per the global binary-files rule.
- **Palette is locked to Lospec AYY4** (`scripts/palette.gd`): INK `#00303b`,
  CORAL `#ff7777`, PEACH `#ffce96`, CREAM `#f1f2da`. Never introduce a fifth
  colour; pick from `Palette.*` only.

## Commands

- Run: `godot --path .`
- Headless syntax/parse check (no window): `godot --headless --path . --quit`
- **After adding a `class_name` script** the global class cache must be
  rebuilt or the headless run fails with "Could not find type X":
  `godot --headless --editor --path . --quit-after 1`. This also writes the
  `.uid` file next to the script — commit it.
- No test framework yet — verified by playing it (Xephyr + xdotool works
  well). If test coverage is added later, prefer GUT (Godot Unit Test).

## Architecture

- `project.godot` — autoloads `GameState`, fixes the window to the world size
  (960x640) so no camera is needed, cream clear colour.
- `scripts/palette.gd` — the four colours.
- `scripts/save_store.gd` — `user://save.json` read/write; corrupt or missing
  file reads as an empty dict.
- `scripts/game_state.gd` — money, current car, damage, catalog (`CarModel`:
  id/name/price/max_health/capacity/size/body/trim), `speed_factor()` (lerps
  1.0 → 0.4 with damage), `repair()` ($2 per point), `buy_car()`. Persists
  after every mutation and restores in `_ready`.
- `scripts/car.gd` — `CharacterBody2D`; arrow movement scaled by
  `speed_factor()`, rotates to face velocity, applies damage on hard
  collisions, draws body/wheels/windows/passenger heads/dents.
- `scripts/pickup_point.gd` / `destination_point.gd` — `Area2D` markers.
  Pickup checks `passengers < capacity`; destination carries its `fare`.
- `scripts/garage.gd` — `Area2D` zone (bottom-left, clear of the HUD).
- `scripts/ground.gd` — road grid, `z_index = -1`.
- `scripts/hud.gd` — `CanvasLayer`; readout + garage panel. Emits
  `buy_requested`/`repair_requested`; `main.gd` decides.
- `scripts/main.gd` — builds the world, keeps three tourists waiting (never
  under the HUD corner or on the garage), prices fares by distance, wires
  every signal.

Every entity is built via a static `create()` factory instead of a `.tscn`
scene file, so adding a new entity type means one new script, not a scene +
script pair.

## Pitfalls

- Never `queue_free()` inside a `body_entered` handler — the physics server
  is mid-flush and crashes. Use `call_deferred("queue_free")`.
- `Button` defaults to the grey engine theme; `Hud._button()` restyles every
  state. New controls must do the same or they break the palette.

## Conventions

- Tabs for indentation (Godot/GDScript convention), typed GDScript
  (`var x: int`, typed function returns) throughout.
- One responsibility per script; `main.gd` orchestrates but game objects own
  their own behavior.
- Work directly on `main`, commit and push without asking (per global
  git-rules). End commits with
  `Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>`.
