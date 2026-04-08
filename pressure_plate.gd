extends Area2D
signal pressure_activated
signal pressure_deactivated

@export var activation_color: Color = Color(0.2, 0.8, 0.2)
@export var deactivation_color: Color = Color(0.5, 0.5, 0.5)
@export var pulse_speed: float = 2.0

var sprite: Sprite2D
var original_modulate: Color
var is_activated: bool = false

func _ready() -> void:
	sprite = $Sprite2D
	if sprite:
		original_modulate = sprite.modulate
		# Set initial state
		sprite.modulate = deactivation_color
	
	# Connect body entered/exited signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body) -> void:
	if body.is_in_group("player") and not is_activated:
		is_activated = true
		if sprite:
			sprite.modulate = activation_color
			# Start pulsing effect
			$PulseTimer.start()
		pressure_activated.emit()

func _on_body_exited(body) -> void:
	if body.is_in_group("player") and is_activated:
		is_activated = false
		if sprite:
			sprite.modulate = deactivation_color
			$PulseTimer.stop()
		pressure_deactivated.emit()

func _pulse_timer_timeout() -> void:
	if sprite and is_activated:
		# Simple pulse effect
		var pulse = sin(Time.get_ticks_msec() / 1000.0 * pulse_speed) * 0.3 + 0.7
		sprite.modulate = activation_color * pulse