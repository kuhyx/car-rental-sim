extends Area2D
class_name DestinationPoint
## Drop-off flag for one passenger. Reaching it with anyone aboard pays `fare`.

signal tourist_dropped_off(point: DestinationPoint)

const RADIUS := 18.0

var fare: int = 0

static func create(pos: Vector2, p_fare: int) -> DestinationPoint:
	var point := DestinationPoint.new()
	point.position = pos
	point.fare = p_fare
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = RADIUS
	shape.shape = circle
	point.add_child(shape)
	return point

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _draw() -> void:
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 32, Palette.INK, 2.0)
	draw_circle(Vector2.ZERO, 3.0, Palette.CORAL)
	# Flag on a pole.
	draw_line(Vector2(0.0, 8.0), Vector2(0.0, -18.0), Palette.INK, 2.0)
	draw_polygon(
		PackedVector2Array([Vector2(1.0, -18.0), Vector2(15.0, -13.0), Vector2(1.0, -8.0)]),
		PackedColorArray([Palette.CORAL])
	)

func _on_body_entered(body: Node2D) -> void:
	if body is Car and body.passengers > 0:
		body.passengers -= 1
		tourist_dropped_off.emit(self)
