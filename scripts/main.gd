extends Node2D
## Wires up the world: ground, walls, garage, car, tourist spawning, and HUD.

const WORLD_SIZE := Vector2(960, 640)
const WALL_THICKNESS := 20.0
const SPAWN_MARGIN := 80.0
## Bottom-left, clear of the HUD readout in the top-left corner.
const GARAGE_POS := Vector2(70, 570)
const GARAGE_CLEARANCE := 110.0
const MAX_WAITING := 3
const FARE_PER_100_PX := 8.0
const BASE_FARE := 24.0
const BADLY_DAMAGED_PERCENT := 80.0
## The HUD readout sits over this corner; anything spawned under it is invisible.
const HUD_CORNER := Rect2(0, 0, 400, 160)

var car: Car
var garage: Garage
var hud: Hud
var pickups: Array[PickupPoint] = []
var player_in_garage: bool = false

func _ready() -> void:
	add_child(Ground.create(WORLD_SIZE))
	_build_world_bounds()

	garage = Garage.create(GARAGE_POS)
	add_child(garage)
	garage.player_entered.connect(_on_garage_entered)
	garage.player_exited.connect(_on_garage_exited)

	car = Car.create()
	car.position = WORLD_SIZE / 2.0
	add_child(car)
	car.passengers_changed.connect(func(count: int) -> void: hud.set_passengers(count))

	hud = Hud.create(WORLD_SIZE / 2.0)
	add_child(hud)
	hud.buy_requested.connect(_on_buy_requested)
	hud.repair_requested.connect(_on_repair_requested)
	GameState.money_changed.connect(hud.set_money)
	GameState.damage_changed.connect(_on_damage_changed)
	GameState.car_changed.connect(func(_id: String) -> void: hud.set_passengers(car.passengers))
	hud.set_money(GameState.money)
	hud.set_damage()
	hud.set_passengers(0)
	hud.set_status("Drive into a waiting tourist to pick them up")

	_ensure_pickups()

func _process(_delta: float) -> void:
	if player_in_garage and Input.is_action_just_pressed("ui_accept"):
		hud.toggle_garage()

func _build_world_bounds() -> void:
	var walls := [
		Rect2(Vector2(0, -WALL_THICKNESS), Vector2(WORLD_SIZE.x, WALL_THICKNESS)),
		Rect2(Vector2(0, WORLD_SIZE.y), Vector2(WORLD_SIZE.x, WALL_THICKNESS)),
		Rect2(Vector2(-WALL_THICKNESS, 0), Vector2(WALL_THICKNESS, WORLD_SIZE.y)),
		Rect2(Vector2(WORLD_SIZE.x, 0), Vector2(WALL_THICKNESS, WORLD_SIZE.y)),
	]
	for wall_rect in walls:
		var wall := StaticBody2D.new()
		var shape := CollisionShape2D.new()
		var rect_shape := RectangleShape2D.new()
		rect_shape.size = wall_rect.size
		shape.shape = rect_shape
		shape.position = wall_rect.position + wall_rect.size / 2.0
		wall.add_child(shape)
		add_child(wall)

## A random spot inside the kerb that is neither on the garage nor under the HUD.
func _random_spot() -> Vector2:
	while true:
		var pos := Vector2(
			randf_range(SPAWN_MARGIN, WORLD_SIZE.x - SPAWN_MARGIN),
			randf_range(SPAWN_MARGIN, WORLD_SIZE.y - SPAWN_MARGIN))
		if pos.distance_to(GARAGE_POS) > GARAGE_CLEARANCE and not HUD_CORNER.has_point(pos):
			return pos
	return WORLD_SIZE / 2.0

func _ensure_pickups() -> void:
	while pickups.size() < MAX_WAITING:
		var pickup := PickupPoint.create(_random_spot())
		add_child(pickup)
		pickup.tourist_picked_up.connect(_on_tourist_picked_up)
		pickups.append(pickup)

func _on_tourist_picked_up(point: PickupPoint) -> void:
	pickups.erase(point)
	# Freeing inside the physics callback that fired this signal crashes the
	# physics server, so defer it.
	point.call_deferred("queue_free")
	var dest_pos := _random_spot()
	var fare := int(BASE_FARE + FARE_PER_100_PX * point.position.distance_to(dest_pos) / 100.0)
	var destination := DestinationPoint.create(dest_pos, fare)
	add_child(destination)
	destination.tourist_dropped_off.connect(_on_tourist_dropped_off)
	hud.set_status("Tourist aboard -- deliver to a flag for $%d" % fare)
	_ensure_pickups()

func _on_tourist_dropped_off(point: DestinationPoint) -> void:
	GameState.add_money(point.fare)
	point.call_deferred("queue_free")
	hud.set_status("Delivered! +$%d" % point.fare)

func _on_damage_changed(_damage: float) -> void:
	hud.set_damage()
	if GameState.damage_percent() >= BADLY_DAMAGED_PERCENT:
		hud.set_status("Car badly damaged -- it's crawling. Repair at the garage")

func _on_garage_entered() -> void:
	player_in_garage = true
	hud.set_status("Press Enter to open the garage")

func _on_garage_exited() -> void:
	player_in_garage = false
	hud.hide_garage()

func _on_buy_requested(car_id: String) -> void:
	if car.passengers > 0:
		hud.set_status("Drop your passengers off before switching cars")
	elif GameState.buy_car(car_id):
		hud.set_status("Bought %s!" % GameState.current_car.display_name)
	else:
		hud.set_status("Can't afford that, or you already own it")

func _on_repair_requested() -> void:
	if GameState.repair():
		hud.set_status("Repaired -- good as new")
	else:
		hud.set_status("Can't afford the repair")
