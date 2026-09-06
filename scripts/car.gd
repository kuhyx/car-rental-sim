extends CharacterBody2D
class_name Car
## Player-controlled car: top-down movement, collision damage, and a
## procedurally drawn body that shows passengers and accumulated dents.

signal passengers_changed(count: int)

const ACCELERATION := 600.0
const FRICTION := 400.0
const MAX_SPEED := 260.0
const DAMAGE_SPEED_THRESHOLD := 80.0
const DAMAGE_PER_IMPACT_SPEED := 0.15
const MAX_SCRATCHES := 5

var passengers: int = 0:
	set(value):
		passengers = value
		passengers_changed.emit(passengers)
		queue_redraw()

var shape_rect: RectangleShape2D

static func create() -> Car:
	var car := Car.new()
	var shape := CollisionShape2D.new()
	car.shape_rect = RectangleShape2D.new()
	car.shape_rect.size = GameState.current_car.size
	shape.shape = car.shape_rect
	car.add_child(shape)
	return car

func _ready() -> void:
	GameState.car_changed.connect(func(_id: String) -> void:
		shape_rect.size = GameState.current_car.size
		queue_redraw())
	GameState.damage_changed.connect(func(_damage: float) -> void: queue_redraw())

func _physics_process(delta: float) -> void:
	var input_dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	var factor := GameState.speed_factor()
	if input_dir.length() > 0.0:
		velocity += input_dir.normalized() * ACCELERATION * factor * delta
		velocity = velocity.limit_length(MAX_SPEED * factor)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	if velocity.length() > 1.0:
		# The sprite points up, so "up" is the car's forward vector.
		rotation = velocity.angle() + PI / 2.0

	var speed_before := velocity.length()
	move_and_slide()

	if get_slide_collision_count() > 0:
		var impact_speed: float = speed_before - velocity.length()
		if impact_speed > DAMAGE_SPEED_THRESHOLD:
			GameState.apply_damage(impact_speed * DAMAGE_PER_IMPACT_SPEED)

func _draw() -> void:
	var model: GameState.CarModel = GameState.current_car
	var w := model.size.x
	var h := model.size.y
	var body := Rect2(-w / 2.0, -h / 2.0, w, h)

	# Wheels first so the body overlaps their inner edge.
	for side: float in [-1.0, 1.0]:
		var x: float = side * (w / 2.0 + 1.0) - 1.5
		draw_rect(Rect2(x, -h / 2.0 + 6.0, 3.0, 10.0), model.trim)
		draw_rect(Rect2(x, h / 2.0 - 16.0, 3.0, 10.0), model.trim)

	draw_rect(body, model.body)
	draw_rect(body, model.trim, false, 2.0)
	# Windscreen and rear window.
	draw_rect(Rect2(-w / 2.0 + 4.0, -h / 2.0 + 7.0, w - 8.0, h * 0.2), model.trim)
	draw_rect(Rect2(-w / 2.0 + 4.0, h / 2.0 - h * 0.18 - 6.0, w - 8.0, h * 0.18), model.trim)
	# Headlights.
	draw_rect(Rect2(-w / 2.0 + 3.0, -h / 2.0 + 1.0, 5.0, 3.0), Palette.CREAM)
	draw_rect(Rect2(w / 2.0 - 8.0, -h / 2.0 + 1.0, 5.0, 3.0), Palette.CREAM)
	if model.capacity >= 3:
		# Roof rack: the SUV's tell.
		draw_line(Vector2(-w / 2.0 + 5.0, -3.0), Vector2(w / 2.0 - 5.0, -3.0), model.trim, 2.0)
		draw_line(Vector2(-w / 2.0 + 5.0, 3.0), Vector2(w / 2.0 - 5.0, 3.0), model.trim, 2.0)

	_draw_passengers(model, w)
	_draw_scratches(model, w, h)

func _draw_passengers(model: GameState.CarModel, w: float) -> void:
	var slots := maxi(model.capacity - 1, 1)
	for i in passengers:
		var x := -w / 4.0 + (w / 2.0) * i / slots if model.capacity > 1 else 0.0
		var head := Vector2(x, 0.0)
		draw_circle(head, 5.0, model.trim)
		draw_circle(head, 3.5, Palette.PEACH if model.body != Palette.PEACH else Palette.CREAM)

## Dents appear one per 20% damage, always in the same places so they read
## as accumulating rather than flickering.
func _draw_scratches(model: GameState.CarModel, w: float, h: float) -> void:
	var count := mini(int(GameState.damage_percent() / 20.0), MAX_SCRATCHES)
	for i in count:
		var y := -h / 2.0 + 10.0 + i * (h - 20.0) / MAX_SCRATCHES
		var x := (-w / 2.0 + 5.0) if i % 2 == 0 else (w / 2.0 - 5.0)
		var dir := 1.0 if i % 2 == 0 else -1.0
		draw_line(Vector2(x, y), Vector2(x + 8.0 * dir, y + 5.0), model.trim, 2.0)
		draw_line(Vector2(x + 8.0 * dir, y + 5.0), Vector2(x + 4.0 * dir, y + 9.0), model.trim, 2.0)
