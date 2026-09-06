extends Area2D
class_name Garage
## Zone where the player can open the buy-a-car panel.

signal player_entered
signal player_exited

const SIZE := Vector2(64, 64)

static func create(pos: Vector2) -> Garage:
	var garage := Garage.new()
	garage.position = pos

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = SIZE
	shape.shape = rect
	garage.add_child(shape)

	var visual := ColorRect.new()
	visual.size = SIZE
	visual.position = -SIZE / 2.0
	visual.color = Color8(150, 100, 40)
	garage.add_child(visual)

	return garage

func _ready() -> void:
	body_entered.connect(func(body: Node2D) -> void:
		if body is Car:
			player_entered.emit())
	body_exited.connect(func(body: Node2D) -> void:
		if body is Car:
			player_exited.emit())
