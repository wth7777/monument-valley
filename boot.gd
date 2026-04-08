extends Node

func _ready() -> void:
	print("=== Monument Valley Godot Project ===")
	print("Project location: necodemus/projects/monument_valley/")
	print("Godot version: ", Engine.get_version_info().string)
	print("")
	print("Key Godot 4.x concepts for this project:")
	print("1. Orthographic camera (Camera2D with zoom)")
	print("2. Isometric TileMap with diamond tiles")
	print("3. CharacterBody2D for player movement")
	print("4. Touch controls (native on Android)")
	print("5. Android export via Project > Export")
	print("")
	print("To run: godot4 --path necodemus/projects/monument_valley/")
