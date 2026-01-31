extends Control

# ------------------------------
# EXPORTS (Textures for pause button states)
# ------------------------------
@export var normal_texture: Texture
@export var pressed_texture: Texture

# ------------------------------
# NODES (References to UI and game objects)
# ------------------------------
@onready var pause_menu = $Menu/PauseMenu
@onready var dialogic = Dialogic
@onready var menu = $Menu
@onready var display_version = $Menu/GameVersion
@onready var press_pause = $PressPause
@onready var music = $Music
@onready var quit_button = $Menu/PauseMenu/Quit
@onready var click = %Click

# ------------------------------
# VARIABLES (Project settings / version info)
# ------------------------------
@onready var version = ProjectSettings.get_setting("application/config/version")

# ------------------------------
# READY (Initialization when scene starts)
# ------------------------------
func _ready() -> void:
	press_pause.icon = normal_texture
	display_version.text = "BALLGAME " + version
	menu.visible = false
	match OS.get_name():
		"Web":
			quit_button.visible = false

# ------------------------------
# PAUSE SYSTEM (Pause and Resume handling)
# ------------------------------
func toggle_pause() -> void:
	if get_tree().paused:
		resume()
	else:
		pause()

func pause() -> void:
	if click:
		click.play()
	press_pause.icon = pressed_texture
	get_tree().paused = true
	menu.visible = true
	music.play()

func resume() -> void:
	if click:
		click.play()
	press_pause.icon = normal_texture
	get_tree().paused = false
	menu.visible = false
	music.stop()

# ------------------------------
# INPUT (Handles pause key press)
# ------------------------------
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		toggle_pause()

# ------------------------------
# MENU BUTTONS (Callbacks for UI buttons)
# ------------------------------
func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	if click:
		click.play()
	
	LoadingService.reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	
	if click:
		click.play()
		
	# End Dialogic timeline if one is active
	if dialogic and dialogic.current_timeline:
		dialogic.end_timeline()

	# Wait one frame to ensure everything processes before quitting
	await get_tree().process_frame
	get_tree().quit()

func _on_press_pause_pressed() -> void:
	toggle_pause()
	
	# Refresh the pause button to ensure proper state
	press_pause.hide()
	press_pause.show()
