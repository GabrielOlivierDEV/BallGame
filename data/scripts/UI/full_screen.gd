extends Node

# ----------------------------
#       FULLSCREEN TOGGLE
# ----------------------------

# Toggle fullscreen mode when the "full_screen" action is pressed
var full_screen = false

# ----------------------------
#       FULLSCREEN METHODS
# ----------------------------

# Listen for input events
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("full_screen"):
		change_screen_mode()

# Switch to fullscreen mode
# Await a frame to ensure the mode change is applied before updating the variable
func _full_screen():
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	await get_tree().process_frame
	full_screen = true

# Switch to windowed mode
# Await a frame to ensure the mode change is applied before updating the variable
func window():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	await get_tree().process_frame
	full_screen = false

# Toggle between fullscreen and windowed modes
func change_screen_mode():
	if full_screen:
		window()
	if not full_screen:
		_full_screen()
