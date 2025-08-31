extends Control

# ------------------------------
# NODES
# ------------------------------
@onready var hint = $Hint
@onready var loading = $Animation/HBoxContainer/Loading
@onready var periods = $Animation/HBoxContainer/periods

# ------------------------------
# VARIABLES
# ------------------------------
var progress = []                # Stores the loading progress of the next scene
var delay_to_read = true         # Adds a short delay to allow the player to read the hint

# List of random hint texts that will be displayed during loading
var hint_texts = [
	"Oi",
	"Hello",
	"Hi"
]

# ------------------------------
# READY
# ------------------------------
func _ready() -> void:
	# Clears any text from "periods" (used for animated dots/loading effect)
	periods.text = ""
	
	# Ensures the game is not paused while loading
	get_tree().paused = false
	
	# Starts the loading animation
	loading.play()

	# Selects and shows a random hint from the list
	hint.text = hint_texts[randi() % hint_texts.size()]
	
	# Waits 1 frame to ensure UI is properly displayed
	await get_tree().process_frame  
	
	# If enabled, adds a short delay before starting the actual loading
	if delay_to_read == true:
		await get_tree().create_timer(1.0).timeout 

	# Begins threaded loading of the target scene (async loading in background)
	ResourceLoader.load_threaded_request(LoadingService.target_scene)

# ------------------------------
# PROCESS
# ------------------------------
func _process(_delta) -> void:
	# Continuously checks the loading progress of the target scene
	ResourceLoader.load_threaded_get_status(LoadingService.target_scene, progress)
	
	# If loading is complete (status = 1), get the scene and change to it
	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(LoadingService.target_scene)
		get_tree().change_scene_to_packed(packed_scene)
