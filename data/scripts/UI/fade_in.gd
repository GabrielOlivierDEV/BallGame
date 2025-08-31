extends ColorRect

@export var fade_time := 1.0  # Total time to fade out (in seconds)
@export var fade_steps := 10  # Number of steps for fade (more = smoother)

const FULL_OPACITY := 1.0
const ZERO_OPACITY := 0.0

var step := 0
var timer: Timer

func _ready():
	modulate.a = FULL_OPACITY
	visible = true
	step = 0

	timer = Timer.new()
	timer.wait_time = fade_time / fade_steps
	timer.one_shot = false
	timer.autostart = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	add_child(timer)

func _on_timer_timeout():
	step += 1
	var new_alpha := FULL_OPACITY - (step / float(fade_steps))
	modulate.a = clamp(new_alpha, ZERO_OPACITY, FULL_OPACITY)

	if step >= fade_steps:
		visible = false
		timer.stop()
		timer.queue_free()
