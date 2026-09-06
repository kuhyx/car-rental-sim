extends Area2D
class_name Garage
## Zone where the player can open the buy/repair panel. Drawn as a small
## building with a roller door.

signal player_entered
signal player_exited

const SIZE := Vector2(80, 64)

static func create(pos: Vector2) -> Garage:
	var garage := Garage.new()
	garage.position = pos
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = SIZE
	shape.shape = rect
	garage.add_child(shape)

	var sign := Label.new()
	sign.text = "GARAGE"
	sign.add_theme_color_override("font_color", Palette.CREAM)
	sign.add_theme_font_size_override("font_size", 11)
	sign.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sign.position = Vector2(-SIZE.x / 2.0, -SIZE.y / 2.0 - 1.0)
	sign.size = Vector2(SIZE.x, 14.0)
	garage.add_child(sign)
	return garage

func _ready() -> void:
	body_entered.connect(func(body: Node2D) -> void:
		if body is Car:
			player_entered.emit())
	body_exited.connect(func(body: Node2D) -> void:
		if body is Car:
			player_exited.emit())

func _draw() -> void:
	var half := SIZE / 2.0
	draw_rect(Rect2(-half, SIZE), Palette.INK)
	draw_rect(Rect2(-half.x, -half.y, SIZE.x, 12.0), Palette.CORAL)
	# Roller door with three slats.
	draw_rect(Rect2(-18.0, -8.0, 36.0, 40.0), Palette.PEACH)
	for i in 3:
		var y := 2.0 + i * 10.0
		draw_line(Vector2(-18.0, y), Vector2(18.0, y), Palette.INK, 1.5)
	# Apron: the zone in front of the door where the car parks.
	draw_rect(Rect2(-half.x, half.y - 4.0, SIZE.x, 4.0), Palette.CORAL)
