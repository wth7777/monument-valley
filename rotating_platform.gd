extends Node2D
class_name RotatingPlatform

signal rotated(platform: Node2D)

var grid_position: Vector2
var is_rotating := false
var target_rotation: float
var rotation_speed := 180.0

func _ready() -> void:
	_draw_platform()

func _draw_platform() -> void:
	# Draw a hexagon-like platform that can rotate
	var points := PackedVector2Array([
		Vector2(0, -24),
		Vector2(20, -12),
		Vector2(20, 12),
		Vector2(0, 24),
		Vector2(-20, 12),
		Vector2(-20, -12)
	])
	
	var polygon := Polygon2D.new()
	polygon.polygon = points
	polygon.color = Color(0.9, 0.6, 0.2, 1.0)
	add_child(polygon)
	
	# Add directional indicator (path connector)
	var arrow := Polygon2D.new()
	var arrow_points := PackedVector2Array([
		Vector2(0, -18),
		Vector2(8, -8),
		Vector2(-8, -8)
	])
	arrow.polygon = arrow_points
	arrow.color = Color(1.0, 0.9, 0.5, 1.0)
	arrow.position = Vector2(0, 0)
	add_child(arrow)
	
	# Add border
	var outline := Line2D.new()
	outline.points = points
	outline.closed = true
	outline.width = 2.0
	outline.default_color = Color(1.0, 0.8, 0.3, 1.0)
	add_child(outline)

func rotate_once() -> void:
	if is_rotating:
		return
	
	is_rotating = true
	target_rotation = rotation_degrees + 90.0

func _process(delta: float) -> void:
	if is_rotating:
		var diff := target_rotation - rotation_degrees
		if abs(diff) < 2.0:
			rotation_degrees = target_rotation
			is_rotating = false
			rotated.emit(self)
		else:
			rotation_degrees += sign(diff) * rotation_speed * delta