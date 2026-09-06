# Car Rental Sim

A tiny top-down car rental sim: pick up tourists, drive them to their flag,
get paid, and watch your car take damage from crashes. A damaged car crawls;
fix it at the garage or save up for a sturdier one with more seats.

Built with Godot 4 (GL Compatibility renderer). No image assets — every
visual is drawn in code with the Lospec **AYY4** palette
(<https://lospec.com/palette-list/ayy4>), so the whole repo is text.

## Run it

```
godot --path .
```

## Controls

- Arrow keys: drive
- Enter: open/close the garage panel while parked on the garage (bottom-left)

## How it plays

- Three tourists are always waiting. Drive into one to pick them up; a flag
  appears with their fare (base $24 + $8 per 100 px of trip).
- Each car has seats: hatchback 1, sedan 2, SUV 3. Carry several tourists at
  once and deliver them in any order.
- Hard collisions dent the car. At 100% damage it moves at 40% speed. Repair
  costs $2 per damage point; or buy a new car (the old one is traded away).
- Progress (money, damage, current car) is saved after every change to
  `user://save.json` — on Linux that is
  `~/.local/share/godot/app_userdata/Car Rental Sim/save.json`. Delete it to
  start over.

## Structure

- `project.godot` — engine config, autoloads, window size, cream clear colour.
- `scenes/Main.tscn` — minimal root scene; everything else is built in code.
- `scripts/palette.gd` — the four AYY4 colours; nothing else defines a colour.
- `scripts/game_state.gd` — autoloaded singleton: money, damage, car catalog,
  repair, speed penalty, persistence.
- `scripts/save_store.gd` — JSON read/write of the save file.
- `scripts/car.gd` — player car: movement, collision damage, drawn body with
  passenger heads and dents.
- `scripts/pickup_point.gd` / `destination_point.gd` — tourist and flag.
- `scripts/garage.gd` — the repair/buy zone.
- `scripts/ground.gd` — road grid backdrop.
- `scripts/hud.gd` — readout and the garage panel.
- `scripts/main.gd` — spawns everything and wires the signals together.
