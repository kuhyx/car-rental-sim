# Car Rental Sim

A tiny top-down car rental sim: pick up tourists, drive them to their
destination, get paid, and watch your car take damage from crashes. Visit the
garage to buy a sturdier car once you can afford one.

Built with Godot 4 (GL Compatibility renderer). No image assets — every
visual is a plain `ColorRect`/`Label`, so the whole repo is text.

## Run it

```
godot4 --path . 2>/dev/null || godot --path .
```

## Controls

- Arrow keys / WASD: drive
- Enter: open/close the garage panel while standing on the garage (top-left,
  dark gray square)

## Structure

- `project.godot` — engine config, autoloads, window size.
- `scenes/Main.tscn` — minimal root scene; everything else is built in code.
- `scripts/game_state.gd` — autoloaded singleton: money, damage, car catalog.
- `scripts/car.gd` — player car: movement + collision damage.
- `scripts/pickup_point.gd` / `destination_point.gd` — tourist pickup/drop-off.
- `scripts/garage.gd` — buy-a-car zone.
- `scripts/main.gd` — spawns everything and drives the HUD.
