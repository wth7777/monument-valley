extends Control
class_name GameUI

@onready var level_label: Label = $LevelLabel
@onready var instructions: Label = $Instructions
@onready var victory_label: Label = $VictoryLabel

func update_level(level_num: int, level_name: String) -> void:
	level_label.text = "Level " + str(level_num) + ": " + level_name
	victory_label.visible = false

func show_victory() -> void:
	victory_label.visible = true
	level_label.text = "Congratulations!"
	instructions.text = "You completed all puzzles!"

func _ready() -> void:
	victory_label.visible = false