extends CanvasLayer

# ------------------------------
# NODES
# ------------------------------
@onready var hint = $Hint
@onready var loading = $Animation/HBoxContainer/Loading
@onready var periods = $Animation/HBoxContainer/Periods

# ------------------------------
# VARIABLES
# ------------------------------
var progress = [] # Stores the loading progress of the next scene
var delay_to_read: bool = true # Adds a short delay to allow the player to read the hint
var settings := ConfigFile.new() # Used to load settings
var loaded_concluded: bool = false # Flag to ensure loading completion is handled once

# ------------------------------
# CONSTANTS
# ------------------------------
const HINTS_FILE = "res://data/hints.json"

# List of random hint texts that will be displayed during loading
var hint_texts: Array = []

# ------------------------------
# READY
# ------------------------------
func _ready() -> void:
	# Ensures the game is not paused while loading
	get_tree().paused = false
	
	# Loads hint texts from the JSON file, then shows a hint immediately
	_load_hint_json(HINTS_FILE)
	hint.text = hint_texts.pick_random()

	# Starts the loading animation (visible while we optionally wait a short delay)
	loading.play()

	# Checks if a delay is needed and wait if required before beginning the actual load
	await _check_delay()

	# Begins threaded loading of the target scene (async loading in background)
	ResourceLoader.load_threaded_request(LoadingService.target_scene)

# ------------------------------
# PROCESS
# ------------------------------
func _process(_delta) -> void:
	# Continuously checks the loading progress of the target scene
	ResourceLoader.load_threaded_get_status(LoadingService.target_scene, progress)
	if not loaded_concluded:
		_progress_periods()
	
	# If loading is complete (status = 1), get the scene and change to it
	if progress[0] == 1:
		await get_tree().process_frame
		loaded_concluded = true
		var packed_scene = ResourceLoader.load_threaded_get(LoadingService.target_scene)
		progress.clear()
		
		# Waits for any active Dialogic timeline to finish before changing scenes
		if Dialogic.current_timeline:
			await Dialogic.timeline_ended
		
		else:
			LoadingService.target_scene = ""
			get_tree().change_scene_to_packed(packed_scene)

# ------------------------------
# PRIVATE FUNCTIONS
# ------------------------------
func _progress_periods():
	# Updates the loading periods animation based on progress
	if progress[0] == 0:
		periods.text = "."
	if progress[0] == 1:
		periods.text = "..."

func _check_delay():
	if delay_to_read == true:
		await get_tree().create_timer(1.0).timeout

func _load_hint_json(path: String):
	# Loads hint texts from a JSON file
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Couldn't open hint file: " + path)
		return
	
	var raw_text := file.get_as_text()
	var data = JSON.parse_string(raw_text)
	
	# Validates the JSON structure
	if typeof(data) != TYPE_DICTIONARY or not data.has("hints"):
		push_error("JSON invalid: must have 'hints'")
		return
	
	# Ensures 'hints' is an array
	if typeof(data["hints"]) == TYPE_ARRAY:
		hint_texts = data["hints"]
