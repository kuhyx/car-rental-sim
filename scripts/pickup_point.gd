extends Area2D
class_name PickupPoint
## A waiting tourist. Drive into them with a free seat to pick them up.

signal tourist_picked_up(point: PickupPoint)

const RADIUS := 18.0

static func create(pos: Vector2) -> PickupPoint:
	var point := PickupPoint.new()
	point.position = pos
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = RADIUS
	shape.shape = circle
	point.add_child(shape)
	return point

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _draw() -> void:
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 32, Palette.CORAL, 2.0)
	# Suitcase, body, head -- a tourist in three shapes.
	draw_rect(Rect2(6.0, 2.0, 6.0, 9.0), Palette.INK)
	draw_rect(Rect2(-5.0, -2.0, 10.0, 12.0), Palette.CORAL)
	draw_circle(Vector2(0.0, -8.0), 5.0, Palette.PEACH)
	draw_arc(Vector2(0.0, -8.0), 5.0, 0.0, TAU, 16, Palette.INK, 1.5)

func _on_body_entered(body: Node2D) -> void:
	if body is Car and body.passengers < GameState.current_car.capacity:
		body.passengers += 1
		tourist_picked_up.emit(self)
