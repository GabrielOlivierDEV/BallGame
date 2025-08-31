extends Node2D

@onready var game = $BallGame
@onready var Screens = $Screens
@onready var lose = $Screens/Lose
@onready var won = $Screens/Won
@onready var menu = $Screens/Menu
@onready var GameBattle = $GameBattle
@onready var End = $End
@onready var CRT = $CRT
@onready var GameUI = $GameUI

# Infinite mode
@export var infinite_mode = false

func _ready() -> void:
	# Play background music for the battle
	GameBattle.play()
	
	# Start the opening dialog
	Dialogic.start("vshana_start")
	
	# Hide screens and game until triggered by dialog
	lose.visible = false
	game.visible = false
	won.visible = false
	
	# Connect to Dialogic's signal system if not already connected
	if Dialogic.signal_event.is_connected(_on_dialogic_signal) == false:
		Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument: String):
	# Handle custom signals sent by Dialogic
	if argument == "start_game":
		# Show the game when dialog says to start
		game.visible = true
	if argument == "reload":
		# Reload the current scene
		call_deferred("reload")
	if argument == "end":
		# Quit the game
		call_deferred("end")
	if argument == "return_to_menu":
		# Quits the game (for now)
		call_deferred("quit")

func win_lose():
	# Make sure this function only runs if the game is visible
	if not game.visible:
		return
	
	# Continue the game if "infinite_mode" is enabled
	if infinite_mode:
		return
	
	# Check if CPU wins (score[1] >= 3)
	if game.score[1] >= 3:
		lose.visible = true
		Dialogic.start("vshana_lose")
		game.visible = false
	
	# Check if Player wins (score[0] >= 3)
	elif game.score[0] >= 3:
		won.visible = true
		GameBattle.stop()
		End.play()
		Dialogic.start("vshana_win")
		game.visible = false

func reload():
	# Reload the current scene (used for restarting the match)
	get_tree().reload_current_scene()

func end():
	# Close the game entirely
	get_tree().quit()

func quit():
	# Same as end() - exits the game
	get_tree().quit()
