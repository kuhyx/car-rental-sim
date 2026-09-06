extends Node2D
class_name Ground
## Static backdrop: a grid of roads with dashed centre lines and a kerb
## around the playable area. Pure `_draw()`, no textures.

const ROAD_WIDTH := 44.0
const ROAD_SPACING := 240.0
const DASH := 14.0
const GAP := 12.0

var world_size: Vector2

static func create(p_world_size: Vector2) -> Ground:
	var ground := Ground.new()
	ground.world_size = p_world_size
	ground.z_index = -1
	return ground

func _draw() -> void:
	var half := ROAD_WIDTH / 2.0
	var x := ROAD_SPACING
	while x < world_size.x:
		draw_rect(Rect2(x - half, 0.0, ROAD_WIDTH, world_size.y), Palette.INK)
		_draw_dashes(Vector2(x, 0.0), Vector2(x, world_size.y))
		x += ROAD_SPACING
	var y := ROAD_SPACING * 2.0 / 3.0
	while y < world_size.y:
		draw_rect(Rect2(0.0, y - half, world_size.x, ROAD_WIDTH), Palette.INK)
		_draw_dashes(Vector2(0.0, y), Vector2(world_size.x, y))
		y += ROAD_SPACING * 2.0 / 3.0
	# Kerb around the map so the invisible walls have a visible edge.
	draw_rect(Rect2(Vector2.ZERO, world_size), Palette.INK, false, 6.0)

func _draw_dashes(from: Vector2, to: Vector2) -> void:
	var dir := (to - from).normalized()
	var length := from.distance_to(to)
	var t := 0.0
	while t < length:
		var end := minf(t + DASH, length)
		draw_line(from + dir * t, from + dir * end, Palette.PEACH, 2.0)
		t += DASH + GAP
