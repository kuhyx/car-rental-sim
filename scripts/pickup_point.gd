extends Area2D
class_name PickupPoint
## A waiting tourist. Drive the car into it to pick them up.

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

	var visual := ColorRect.new()
	visual.size = Vector2(RADIUS, RADIUS) * 2.0
	visual.position = -visual.size / 2.0
	visual.color = Color8(230, 200, 40)
	point.add_child(visual)

	return point

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Car and not body.carrying_tourist:
		body.carrying_tourist = true
		tourist_picked_up.emit(self)
