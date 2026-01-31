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
@onready var click = %Click

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
		# Reload the game
		click.play()
		call_deferred("reload")
	if argument == "quit":
		# Quits the game
		click.play()
		call_deferred("quit")
	if argument == "infinite":
		# Enable infinite mode
		click.play()
		infinite_mode = true
	if argument == "finite":
		# Disable infinite mode
		click.play()
		infinite_mode = false
	if argument == "hard":
		# Enable harder AI
		click.play()
		game.hard_mode = true
	if argument == "easy":
		# Disable harder AI
		click.play()
		game.hard_mode = false
	if argument == "multiplayer":
		# Enable multiplayer (makes CPU paddle playable)
		click.play()
		game.player_two()
		
	if argument == "singleplayer":
		# Maintain the game in singleplayer mode.
		click.play()

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

func quit():
	# exits the game
	get_tree().quit()
