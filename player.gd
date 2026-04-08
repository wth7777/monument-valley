extends CharacterBody2D
class_name Player

var grid_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	_draw_player()

func _draw_player() -> void:
	# Draw a simple character (robed figure)
	var body := Polygon2D.new()
	var body_points := PackedVector2Array([
		Vector2(-10, -20),  # Head top
		Vector2(-6, -14),
		Vector2(0, -12),
		Vector2(6, -14),
		Vector2(10, -20),   # Head right
		Vector2(12, -8),    # Shoulder right
		Vector2(10, 0),
		Vector2(8, 16),     # Robe bottom right
		Vector2(-8, 16),    # Robe bottom left
		Vector2(-10, 0),
		Vector2(-12, -8)    # Shoulder left
	])
	body.polygon = body_points
	body.color = Color(0.3, 0.7, 0.9, 1.0)
	add_child(body)
	
	# Face
	var face := Polygon2D.new()
	face.polygon = PackedVector2Array([
		Vector2(-4, -18),
		Vector2(4, -18),
		Vector2(6, -15),
		Vector2(-6, -15)
	])
	face.color = Color(0.95, 0.85, 0.75, 1.0)
	add_child(face)
	
	# Shadow
	var shadow := Polygon2D.new()
	shadow.polygon = PackedVector2Array([
		Vector2(-12, 18),
		Vector2(12, 18),
		Vector2(8, 14),
		Vector2(-8, 14)
	])
	shadow.color = Color(0, 0, 0, 0.3)
	shadow.position = Vector2(0, 0)
	add_child(shadow)