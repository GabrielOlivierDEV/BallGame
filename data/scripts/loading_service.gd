extends Node

# ------------------------------
# VARIABLES
# ------------------------------
var target_scene: String = ""   # Stores the path of the scene to load
var dialogic = Dialogic
const LOADING_SCREEN_SCENE = "res://data/scenes/loading_screen.tscn"

# ------------------------------
# PUBLIC FUNCTIONS
# ------------------------------

# Requests a scene change through the loading screen
func change_scene(scene_path: String) -> void:
	# Store the target scene path
	target_scene = scene_path
	
	# Defers the call to avoid immediate scene change during the current frame
	call_deferred("_loading_screen")

	get_tree().paused = false

# Reload current scene
func reload_current_scene():
	# Resume game
	get_tree().paused = false
	
	# End current Dialogic timeline if running
	if dialogic:
		dialogic.end_timeline()
	
	# Load screen transition before reloading the current scene
	target_scene = get_tree().current_scene.scene_file_path
	change_scene(LoadingService.target_scene)

# ------------------------------
# PRIVATE FUNCTIONS
# ------------------------------

# Loads the loading screen before switching to the target scene
func _loading_screen() -> void:
	get_tree().change_scene_to_file(LOADING_SCREEN_SCENE)
