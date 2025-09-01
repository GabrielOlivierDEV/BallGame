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
	"Hi",
	"Absolute bongos!",
	"💀",
	"hello everynyan",
	"You get meee\nAnd I get youuu",
	"IT'S NO UUUSE!",
	"OH MAH GAHD",
	"Sata Andagi",
	"Welcome, or welcome back, idk",
	"Gimme your money",
	"100% ghost-free",
	"I see you! :D",
	"It's rated 'R' for Radical!",
	"It's a canon event",
	"How many times have you been here before?",
	"This is canon.",
	"This game is sponsored by",
	"Everything is open-source if you know how to make it",
	"The simplest answer is *probably* the correct one.",
	"if if if if if if else",
	"Made with GDScript",
	"WAIT! They don't love you like I love you <3",
	"Without any community drama!",
	"I've seen this before",
	"Check out the gacha system update!",
	"You're probably wondering how I ended up in this situation",
	"He's right behind me isn't he?",
	"Well, that just happened.",
	"Powered by zeros, ones, love ...and also sorrow.",
	"I'm gonna eat your soul :3",
	"I can feel the love on the air\n ...or maybe it's carbon monoxide.",
	"",
	"🥀",
	"They're watching.",
	"He's here.",
	"Together Forever!",
	"Lore accurate.",
	"aura+ego",
	"Não há razões para sorrir.",
	"Driving in my car right after a beer...",
	"Don't go.",
	"Suki!SukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSukiSuki",
	"THINK FAST CHUCKLENUTS!!!",
	"YN0TM3",
	"I knew that door had a lock on it!",
	"Coming straight to YOUR house!",
	"Single mothers at 50km in your area.",
	"Seven.",
	"Tt's Me.",
	"THE FUNNU NUMB3RR",
	"Playing BallGame in the big 2025 🥀",
	"I die tomorrow",
	"We're in the worst timeline.",
	"IT'S ACTUALLY OVER.",
	"HE'S DONE.",
	"HE'S A FRAUD",
	"IT'S OVER.",
	"FINALLY OVER",
	"THE END",
	"HARUKA GOT CANCELLED",
	"MARRY AND REPRODUCE.",
	#"hello data-miners!"
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
