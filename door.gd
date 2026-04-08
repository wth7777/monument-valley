extends Area2D
signal door_opened
signal door_closed

@export var open_offset: Vector2 = Vector2(0, -50)  # How far to move when open
@export var move_speed: float = 200  # Pixels per second
@export var door_sprite_path: String = "res://diamond_tile.png"

var sprite: Sprite2D
var collision_shape: CollisionShape2D
var original_position: Vector2
var target_position: Vector2
var is_open: bool = false
var is_moving: bool = false

func _ready() -> void:
	sprite = $Sprite2D
	collision_shape = $CollisionShape2D
	original_position = position
	target_position = original_position
	
	# Load door sprite if path provided
	if door_sprite_path and not sprite.texture:
		var texture = load(door_sprite_path)
		if texture:
			sprite.texture = texture
	
	# Ensure we have a collision shape
	if not collision_shape:
		collision_shape = CollisionShape2D.new()
		var rectangle_shape = RectangleShape2D.new()
		rectangle_shape.size = Vector2(32, 64)  # Default door size
		collision_shape.shape = rectangle_shape
		add_child(collision_shape)
		collision_shape.name = "CollisionShape2D"

func open_door() -> void:
	if is_open or is_moving:
		return
	is_open = true
	is_moving = true
	target_position = original_position + open_offset
	door_opened.emit()

func close_door() -> void:
	if not is_open or is_moving:
		return
	is_open = false
	is_moving = true
	target_position = original_position
	door_closed.emit()

func _process(delta) -> void:
	if is_moving:
		var direction = (target_position - position).normalized()
		var distance = position.distance_to(target_position)
		var movement = direction * min(move_speed * delta, distance)
		
		position += movement
		
		if position.distance_to(target_position) < 1.0:
			position = target_position
			is_moving = false

## Note: Door open/close is controlled via signals connected in main.gd
## This allows pressure plates to control doors through the MainGame singleton

## Also support direct Area2D detection as fallback
func _on_area_entered(area) -> void:
	if area.is_in_group("pressure_plate_group"):
		open_door()

func _on_area_exited(area) -> void:
	if area.is_in_group("pressure_plate_group"):
		close_door()