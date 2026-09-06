extends Area2D
class_name DestinationPoint
## Drop-off marker. Reach it while carrying a tourist to collect the fare.

signal tourist_dropped_off(point: DestinationPoint)

const RADIUS := 18.0

static func create(pos: Vector2) -> DestinationPoint:
	var point := DestinationPoint.new()
	point.position = pos

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = RADIUS
	shape.shape = circle
	point.add_child(shape)

	var visual := ColorRect.new()
	visual.size = Vector2(RADIUS, RADIUS) * 2.0
	visual.position = -visual.size / 2.0
	visual.color = Color8(60, 200, 90)
	point.add_child(visual)

	return point

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Car and body.carrying_tourist:
		tourist_dropped_off.emit(self)
