extends Node

# ------------------------------
# VARIABLES
# ------------------------------
var target_scene: String = ""   # Stores the path of the scene to load

# ------------------------------
# PUBLIC FUNCTIONS
# ------------------------------

# Requests a scene change through the loading screen
func change_scene(scene_path: String) -> void:
	# Store the target scene path
	LoadingService.target_scene = scene_path
	
	# Defers the call to avoid immediate scene change during the current frame
	call_deferred("loading_screen")

# ------------------------------
# PRIVATE FUNCTIONS
# ------------------------------

# Loads the loading screen before switching to the target scene
func loading_screen() -> void:
	get_tree().change_scene_to_file("res://addons/brigadeiro_studios_essentials/Loading_Screen/loading_screen.tscn")
