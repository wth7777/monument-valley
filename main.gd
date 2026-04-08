extends Node2D
class_name MainGame

signal level_completed(level_num: int)
signal level_started(level_num: int)

@onready var player: CharacterBody2D = $YSort/Player
@onready var camera: Camera2D = $Camera2D
@onready var tile_container: Node2D = $TileContainer
@onready var platform_container: Node2D = $PlatformContainer
@onready var ui: Control = $UI

var current_level := 1
var target_position: Vector2
var is_moving := false
var path: Array[Vector2] = []
var game_state := "playing" # playing, moving, completed

const MOVE_SPEED := 180.0
const TILE_WIDTH := 64.0
const TILE_HEIGHT := 32.0

# Level data
var levels := {
	1: {
		"name": "The Beginning",
		"tiles": [],
		"platforms": [],
		"start_pos": Vector2(3, 4),
		"goal_pos": Vector2(8, 2),
	},
	2: {
		"name": "The Crossing",
		"tiles": [],
		"platforms": [],
		"start_pos": Vector2(1, 6),
		"goal_pos": Vector2(10, 1),
	},
	3: {
		"name": "The Gauntlet",
		"tiles": [],
		"platforms": [],
		"start_pos": Vector2(0, 8),
		"goal_pos": Vector2(12, 0),
	}
}

# Tile registry for collision and pathfinding
var walkable_tiles: Dictionary = {}
var rotating_platforms: Array[Node2D] = []

func _ready() -> void:
	_setup_level(1)
	_connect_pressure_plates()
	print("Monument Valley Puzzle Game Ready!")

func _connect_pressure_plates() -> void:
	# Connect each pressure plate to its corresponding door by position
	# Get all pressure plates and doors
	var plates = get_tree().get_nodes_in_group("pressure_plate_group")
	var doors = get_tree().get_nodes_in_group("door_group")
	
	# Sort plates and doors by Y position
	plates.sort_custom(func(a, b): return a.position.y < b.position.y)
	doors.sort_custom(func(a, b): return a.position.y < b.position.y)
	
	# Connect each plate to its corresponding door (by index)
	for i in range(min(plates.size(), doors.size())):
		var plate = plates[i]
		var door = doors[i]
		plate.pressure_activated.connect(door.open_door)
		plate.pressure_deactivated.connect(door.close_door)
		print("Connected ", plate.name, " to ", door.name)

func _setup_level(level_num: int) -> void:
	current_level = level_num
	game_state = "playing"
	
	# Clear existing tiles and platforms
	for child in tile_container.get_children():
		child.queue_free()
	for child in platform_container.get_children():
		child.queue_free()
	walkable_tiles.clear()
	rotating_platforms.clear()
	
	# Generate level based on level number using if-elif
	if level_num == 1:
		_generate_level_1()
	elif level_num == 2:
		_generate_level_2()
	elif level_num == 3:
		_generate_level_3()
	
	# Position player at start
	var start_pos = levels[level_num]["start_pos"]
	player.position = _grid_to_iso(start_pos)
	player.grid_position = start_pos
	target_position = player.position
	is_moving = false
	
	# Update UI
	ui.update_level(level_num, levels[level_num]["name"])
	level_started.emit(level_num)
	print("Level ", level_num, " started: ", levels[level_num]["name"])

func _generate_level_1() -> void:
	# Create a simple path with a rotating platform
	var grid_width := 12
	var grid_height := 8
	
	# Floor tiles - L-shaped path
	var path_tiles := [
		Vector2(2,5), Vector2(3,5), Vector2(4,5), Vector2(5,5),
		Vector2(5,4), Vector2(5,3), Vector2(6,3), Vector2(7,3), Vector2(8,3),
		Vector2(8,2), Vector2(8,1), Vector2(9,1), Vector2(10,1)
	]
	
	# Create all floor tiles
	for y in range(grid_height):
		for x in range(grid_width):
			var pos := Vector2(x, y)
			if pos in path_tiles:
				_create_tile(x, y, "floor")
	
	# Create rotating platform in the middle
	_create_rotating_platform(6, 2, 0)
	
	# Add goal marker
	_create_goal_tile(10, 1)

func _generate_level_2() -> void:
	# More complex level with multiple rotating platforms
	var path_tiles := [
		# Left side path
		Vector2(0, 7), Vector2(1, 7), Vector2(2, 7),
		Vector2(2, 6), Vector2(2, 5),
		# Bridge section
		Vector2(3, 5), Vector2(4, 5),
		# Middle platform area
		Vector2(5, 4), Vector2(6, 4), Vector2(7, 4),
		Vector2(7, 3), Vector2(7, 2),
		# Upper path
		Vector2(8, 2), Vector2(9, 2), Vector2(10, 2), Vector2(11, 2)
	]
	
	var grid_height := 10
	var grid_width := 12
	
	for y in range(grid_height):
		for x in range(grid_width):
			var pos := Vector2(x, y)
			if pos in path_tiles:
				_create_tile(x, y, "floor")
	
	# Create multiple rotating platforms
	_create_rotating_platform(4, 4, 0)   # Bridge connector 1
	_create_rotating_platform(6, 3, 90)  # Bridge connector 2
	_create_rotating_platform(9, 1, 180) # Near goal
	
	# Add goal
	_create_goal_tile(11, 2)

func _generate_level_3() -> void:
	# Challenge level with more rotating platforms
	var path_tiles := [
		# Starting area
		Vector2(0, 8), Vector2(1, 8), Vector2(2, 8),
		Vector2(2, 7), Vector2(2, 6),
		Vector2(3, 6), Vector2(4, 6),
		Vector2(4, 5), Vector2(4, 4),
		Vector2(5, 4), Vector2(6, 4),
		Vector2(6, 3), Vector2(6, 2),
		Vector2(7, 2), Vector2(8, 2),
		Vector2(8, 1), Vector2(8, 0),
		Vector2(9, 0), Vector2(10, 0),
		Vector2(11, 0), Vector2(12, 0)
	]
	
	var grid_height := 10
	var grid_width := 14
	
	for y in range(grid_height):
		for x in range(grid_width):
			var pos := Vector2(x, y)
			if pos in path_tiles:
				_create_tile(x, y, "floor")
	
	# Multiple rotating platforms
	_create_rotating_platform(3, 5, 0)
	_create_rotating_platform(5, 3, 90)
	_create_rotating_platform(7, 1, 180)
	_create_rotating_platform(10, 1, 270)
	
	# Add goal
	_create_goal_tile(12, 0)

func _create_tile(grid_x: int, grid_y: int, tile_type: String) -> void:
	var iso_pos := _grid_to_iso(Vector2(grid_x, grid_y))
	var tile: Polygon2D = Polygon2D.new()
	var points := _get_diamond_points(iso_pos)
	tile.polygon = points
	
	match tile_type:
		"floor":
			tile.color = Color(0.25, 0.45, 0.65, 0.9)
		"goal":
			tile.color = Color(0.2, 0.8, 0.3, 1.0)
	
	tile_container.add_child(tile)
	walkable_tiles[Vector2(grid_x, grid_y)] = {"type": tile_type, "iso_pos": iso_pos}

func _create_rotating_platform(grid_x: int, grid_y: int, initial_angle: float) -> void:
	var iso_pos := _grid_to_iso(Vector2(grid_x, grid_y))
	var platform: RotatingPlatform = RotatingPlatform.new()
	platform.position = iso_pos
	platform.grid_position = Vector2(grid_x, grid_y)
	platform.rotation_degrees = initial_angle
	platform.connect("rotated", _on_platform_rotated)
	platform_container.add_child(platform)
	rotating_platforms.append(platform)
	
	# Register as walkable
	walkable_tiles[Vector2(grid_x, grid_y)] = {"type": "platform", "node": platform}

func _create_goal_tile(grid_x: int, grid_y: int) -> void:
	var iso_pos := _grid_to_iso(Vector2(grid_x, grid_y))
	var goal: Polygon2D = Polygon2D.new()
	var points := _get_diamond_points(iso_pos)
	goal.polygon = points
	goal.color = Color(0.2, 0.85, 0.4, 1.0)
	
	# Add glow effect
	var glow: Polygon2D = Polygon2D.new()
	var glow_points := PackedVector2Array()
	for p in points:
		glow_points.append(p + Vector2(0, -8))
	glow.polygon = glow_points
	glow.color = Color(0.4, 1.0, 0.5, 0.4)
	
	tile_container.add_child(goal)
	tile_container.add_child(glow)
	walkable_tiles[Vector2(grid_x, grid_y)] = {"type": "goal", "iso_pos": iso_pos}

func _get_diamond_points(center: Vector2) -> PackedVector2Array:
	var w := TILE_WIDTH / 2.0
	var h := TILE_HEIGHT / 2.0
	return PackedVector2Array([
		center + Vector2(0, -h * 2),
		center + Vector2(w, 0),
		center + Vector2(0, h * 2),
		center + Vector2(-w, 0)
	])

func _grid_to_iso(grid: Vector2) -> Vector2:
	var x := (grid.x - grid.y) * (TILE_WIDTH / 2.0)
	var y := (grid.x + grid.y) * (TILE_HEIGHT / 2.0)
	return Vector2(x, y)

func _iso_to_grid(iso: Vector2) -> Vector2:
	var grid_x := iso.x / (TILE_WIDTH / 2.0) + iso.y / (TILE_HEIGHT / 2.0)
	var grid_y := iso.y / (TILE_HEIGHT / 2.0) - iso.x / (TILE_WIDTH / 2.0)
	return Vector2(int(grid_x / 2.0), int(grid_y / 2.0))

func _is_walkable(grid_pos: Vector2) -> bool:
	return walkable_tiles.has(grid_pos)

func _on_platform_rotated(old_pos: Vector2, new_pos: Vector2) -> void:
	# Update walkable tiles registry when a platform rotates
	if walkable_tiles.has(old_pos):
		var tile_data = walkable_tiles[old_pos]
		walkable_tiles.erase(old_pos)
		walkable_tiles[new_pos] = tile_data

func _physics_process(delta: float) -> void:
	if not is_moving:
		return
	
	var direction := (target_position - player.position).normalized()
	var distance := player.position.distance_to(target_position)
	
	if distance > 5.0:
		player.velocity = direction * MOVE_SPEED
		player.move_and_slide()
	else:
		player.position = target_position
		player.grid_position = _iso_to_grid(target_position)
		
		# Check if reached goal
		if walkable_tiles.has(player.grid_position):
			var tile = walkable_tiles[player.grid_position]
			if tile.get("type") == "goal":
				_game_completed()
				return
		
		# Continue pathfinding
		if path.size() > 0:
			target_position = path[0]
			path.pop_front()
		else:
			is_moving = false
			player.velocity = Vector2.ZERO

func _game_completed() -> void:
	is_moving = false
	game_state = "completed"
	print("Level ", current_level, " completed!")
	level_completed.emit(current_level)
	
	# Load next level after delay
	await get_tree().create_timer(1.5).timeout
	if current_level < 3:
		_setup_level(current_level + 1)
	else:
		print("All levels completed!")

func _input(event: InputEvent) -> void:
	if game_state != "playing" or is_moving:
		return
	
	if event.is_action_pressed("ui_up"):
		_try_move(Vector2(0, -1))
	elif event.is_action_pressed("ui_down"):
		_try_move(Vector2(0, 1))
	elif event.is_action_pressed("ui_left"):
		_try_move(Vector2(-1, 0))
	elif event.is_action_pressed("ui_right"):
		_try_move(Vector2(1, 0))

func _try_move(direction: Vector2) -> void:
	var new_grid_pos: Vector2 = player.grid_position + direction
	
	if _is_walkable(new_grid_pos):
		is_moving = true
		target_position = _grid_to_iso(new_grid_pos)
		path.clear()
	else:
		print("Cannot move to ", new_grid_pos)