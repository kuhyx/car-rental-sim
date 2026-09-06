extends CharacterBody2D
class_name Car
## Player-controlled car: top-down movement plus collision damage.

const ACCELERATION := 600.0
const FRICTION := 400.0
const MAX_SPEED := 260.0
const DAMAGE_SPEED_THRESHOLD := 80.0
const DAMAGE_PER_IMPACT_SPEED := 0.15
const SIZE := Vector2(28, 44)

var carrying_tourist: bool = false
var body_visual: ColorRect

static func create() -> Car:
	var car := Car.new()

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = SIZE
	shape.shape = rect
	car.add_child(shape)

	var visual := ColorRect.new()
	visual.size = SIZE
	visual.position = -SIZE / 2.0
	car.add_child(visual)
	car.body_visual = visual

	return car

func _ready() -> void:
	_sync_visual_color()
	GameState.car_changed.connect(func(_id: String) -> void: _sync_visual_color())

func _physics_process(delta: float) -> void:
	var input_dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	if input_dir.length() > 0.0:
		velocity += input_dir.normalized() * ACCELERATION * delta
		velocity = velocity.limit_length(MAX_SPEED)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	var speed_before := velocity.length()
	move_and_slide()

	if get_slide_collision_count() > 0:
		var impact_speed: float = speed_before - velocity.length()
		if impact_speed > DAMAGE_SPEED_THRESHOLD:
			GameState.apply_damage(impact_speed * DAMAGE_PER_IMPACT_SPEED)

func _sync_visual_color() -> void:
	if body_visual:
		body_visual.color = GameState.current_car.color
