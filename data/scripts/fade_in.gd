extends ColorRect

# ----------------------------
#       FADE OUT EFFECT
# ----------------------------

# Parameters for fade out effect
@export var fade_time := 1.0  # Total time to fade out (in seconds)
@export var fade_steps := 10  # Number of steps for fade (more = smoother)

# Constants for opacity levels
const FULL_OPACITY := 1.0
const ZERO_OPACITY := 0.0

# Internal variables
var step := 0
var timer: Timer

# Initialize the fade out effect
func _ready():
	modulate.a = FULL_OPACITY # Start fully opaque
	visible = true # Ensure the ColorRect is visible
	step = 0 # Reset step counter

	timer = Timer.new() # Create a new Timer node
	timer.wait_time = fade_time / fade_steps # Calculate wait time per step
	timer.one_shot = false # Repeat until stopped
	timer.autostart = true # Start automatically
	timer.connect("timeout", Callable(self, "_on_timer_timeout")) # Connect timeout signal
	add_child(timer) # Add Timer as a child node

# Timer event: gradually decrease opacity
func _on_timer_timeout():
	step += 1 # Increment step counter
	# Calculate new alpha value based on current step
	var new_alpha := FULL_OPACITY - (step / float(fade_steps))
	modulate.a = clamp(new_alpha, ZERO_OPACITY, FULL_OPACITY) 

	# If fade is complete, hide the ColorRect and stop the timer
	if step >= fade_steps:
		visible = false
		timer.stop()
		timer.queue_free()
