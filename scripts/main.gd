extends Node2D
## Wires up the world: walls, garage, car, tourist spawning, and the HUD.

const WORLD_SIZE := Vector2(960, 640)
const WALL_THICKNESS := 20.0
const FARE_PER_100_PX := 8.0
const BASE_FARE := 24.0

var car: Car
var garage: Garage
var destination: DestinationPoint
var player_in_garage: bool = false

var money_label: Label
var damage_label: Label
var status_label: Label
var garage_panel: PanelContainer
var garage_title: Label

func _ready() -> void:
	_build_world_bounds()

	garage = Garage.create(Vector2(60, 60))
	add_child(garage)
	garage.player_entered.connect(_on_garage_entered)
	garage.player_exited.connect(_on_garage_exited)

	car = Car.create()
	car.position = WORLD_SIZE / 2.0
	add_child(car)

	_spawn_pickup()
	_build_hud()

	GameState.money_changed.connect(_update_money_label)
	GameState.damage_changed.connect(_update_damage_label)
	_update_money_label(GameState.money)
	_update_damage_label(GameState.damage)

func _process(_delta: float) -> void:
	if player_in_garage and Input.is_action_just_pressed("ui_accept"):
		garage_panel.visible = not garage_panel.visible

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

func _spawn_pickup() -> void:
	var pos := Vector2(randf_range(80, WORLD_SIZE.x - 80), randf_range(80, WORLD_SIZE.y - 80))
	var pickup := PickupPoint.create(pos)
	add_child(pickup)
	pickup.tourist_picked_up.connect(_on_tourist_picked_up)

func _on_tourist_picked_up(point: PickupPoint) -> void:
	point.call_deferred("queue_free")
	var pos := Vector2(randf_range(80, WORLD_SIZE.x - 80), randf_range(80, WORLD_SIZE.y - 80))
	destination = DestinationPoint.create(pos)
	add_child(destination)
	destination.tourist_dropped_off.connect(_on_tourist_dropped_off)
	status_label.text = "Carrying a tourist -- head to the green marker"

func _on_tourist_dropped_off(point: DestinationPoint) -> void:
	var fare := int(BASE_FARE + FARE_PER_100_PX * (point.position.distance_to(car.position) / 100.0))
	GameState.add_money(fare)
	point.call_deferred("queue_free")
	car.carrying_tourist = false
	status_label.text = "Delivered! +$%d" % fare
	_spawn_pickup()

func _on_garage_entered() -> void:
	player_in_garage = true
	status_label.text = "Press Enter at the garage to manage your car"

func _on_garage_exited() -> void:
	player_in_garage = false
	garage_panel.visible = false

func _build_hud() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	hud.add_child(margin)

	var vbox := VBoxContainer.new()
	margin.add_child(vbox)

	money_label = Label.new()
	vbox.add_child(money_label)

	damage_label = Label.new()
	vbox.add_child(damage_label)

	status_label = Label.new()
	status_label.text = "Drive to the yellow marker to pick up a tourist"
	vbox.add_child(status_label)

	garage_panel = PanelContainer.new()
	garage_panel.visible = false
	garage_panel.position = Vector2(WORLD_SIZE.x / 2.0 - 140, WORLD_SIZE.y / 2.0 - 100)
	hud.add_child(garage_panel)

	var panel_vbox := VBoxContainer.new()
	garage_panel.add_child(panel_vbox)

	garage_title = Label.new()
	garage_title.text = "Garage -- current car: %s" % GameState.current_car.display_name
	panel_vbox.add_child(garage_title)

	for c in GameState.catalog:
		var button := Button.new()
		button.text = "%s -- $%d (durability %d)" % [c.display_name, c.price, int(c.max_health)]
		button.pressed.connect(_on_buy_pressed.bind(c.id))
		panel_vbox.add_child(button)

func _on_buy_pressed(car_id: String) -> void:
	if GameState.buy_car(car_id):
		garage_title.text = "Garage -- current car: %s" % GameState.current_car.display_name
		status_label.text = "Bought %s!" % GameState.current_car.display_name
	else:
		status_label.text = "Can't afford that, or already own it"

func _update_money_label(amount: int) -> void:
	money_label.text = "Money: $%d" % amount

func _update_damage_label(_damage: float) -> void:
	damage_label.text = "Damage: %d%%" % int(GameState.damage_percent())
