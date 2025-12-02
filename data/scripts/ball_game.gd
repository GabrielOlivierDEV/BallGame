extends Node2D

# ----------------------------
#       MAIN VARIABLES
# ----------------------------
var score := [0, 0] # Index: 0 - Player, 1 - CPU
const PADDLE_SPEED: int = 500

@onready var player = $Player
@onready var cpu = $CPU
@onready var ball = $Ball
@onready var borders = $Borders
@onready var glitch = $Glitch

# Character icons
@onready var hana_icon = $CPUScore/HanaIcon
@onready var haruka_icon = $PlayerScore/HarukaIcon

# Timers
@onready var ball_timer = $BallTimer

# Score UI
@onready var player_score = $PlayerScore/Label
@onready var cpu_score = $CPUScore/Label
@onready var score_right = $ScoreRight
@onready var score_left = $ScoreLeft
@onready var player_point = $player_point
@onready var cpu_point = $cpu_point
@onready var cheat = $Player/Cheat

# Other game elements
@onready var win = $win

# Debug configuration
@export var debug_enabled: bool = false  # Set 'false' to disable debug

# Adjust AI difficulty
@export var hard_mode: bool = false

# Debug cheat code (Asmodex sequence)
var asmodex_code := [
	"interact", "move_up", "move_up", "move_down", "move_down", 
	"move_left", "move_right", "move_left", "move_right", "move_down"
]
var input_sequence := []

# ----------------------------
#       GAME METHODS
# ----------------------------

func _ready() -> void:
	cheat.visible = false
	glitch.visible = false
	hana_icon.visible = false
	haruka_icon.visible = false
	ball.visible = false
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _process(_delta: float) -> void:
	# Adjust AI difficulty
	if hard_mode == true:
		cpu.reaction_delay = 0.04  # Faster reaction, harder AI
	else:
		cpu.reaction_delay = 0.2   # Slower reaction, easier AI

func _input(event: InputEvent) -> void:
	# Debug input listener (only works if debug_enabled = true)
	if debug_enabled and event is InputEventKey and event.is_pressed():
		var action_name = _get_action_from_event(event)
		if action_name:
			_update_input_sequence(action_name)
			_check_asmodex_code()
	if event.is_action_pressed("glitch"):
		# Activate glitch mode
		if not glitch:
			return
		glitch.visible = true
		await get_tree().create_timer(2.0).timeout
		player.glitched = true
		cpu.glitched = true
		glitch.queue_free()

	if event.is_action_pressed("debug"):
		# Activate debug mode
		if not cheat:
			return
		debug_enabled = true
		cheat.visible = true
		await get_tree().create_timer(30.0).timeout
		if cheat:
			cheat.queue_free()

# Retrieves the name of the pressed action (if it belongs to the Asmodex code)
func _get_action_from_event(_event: InputEventKey) -> String:
	for action in asmodex_code:
		if Input.is_action_pressed(action):
			return action
	return ""

# Updates the current input sequence with the latest pressed key
func _update_input_sequence(action_name: String) -> void:
	input_sequence.append(action_name)
	if input_sequence.size() > asmodex_code.size():
		input_sequence.pop_front()

# Checks if the current input sequence matches the Asmodex cheat code
func _check_asmodex_code() -> void:
	if input_sequence == asmodex_code:
		_debug_give_points()

# Gives bonus points to the player if the Asmodex code is correctly entered
func _debug_give_points() -> void:
	if Dialogic.current_timeline == null: # Prevents conflicts with dialog
		score[0] += 3
		player_score.text = str(score[0])
		print("Debug: Asmodex Code Activated! +3 points for the player!")
		get_parent().win_lose()
		ball_timer.start()
		input_sequence.clear()
		if not cheat:
			return
		if cheat.visible == true:
			cheat.queue_free()

# ----------------------------
#       PLAYER MOVEMENT
# ----------------------------

# Makes the CPU paddle playable
func player_two():
	cpu.playable = true

# ----------------------------
#       SCORE MANAGEMENT
# ----------------------------

# Adds a point to the CPU
func add_cpu_score() -> void:
	ball.reset_ball()
	score[1] += 1
	cpu_score.text = str(score[1])

# Adds a point to the Player
func add_player_score() -> void:
	ball.reset_ball()
	score[0] += 1
	player_score.text = str(score[0])

# ----------------------------
#       EVENT MANAGEMENT
# ----------------------------

func _on_dialogic_signal(argument: String) -> void:
	if argument == "start_game":
		ball.visible = true
		hana_icon.visible = true
		haruka_icon.visible = true

# Timer event: launches a new ball after a short delay
func _on_ball_timer_timeout() -> void:
	if get_parent().game.visible:
		ball.new_ball()

# ----------------------------
#       SCORE DETECTION
# ----------------------------

# Called when the ball enters the left score zone (CPU scores a point)
func _on_score_left_body_entered(body) -> void:
	if body.is_in_group("ball") and get_parent().game.visible:
		add_cpu_score()
		ball_timer.start()
		cpu_point.play()
		get_parent().win_lose()

# Called when the ball enters the right score zone (Player scores a point)
func _on_score_right_body_entered(body) -> void:
	if body.is_in_group("ball") and get_parent().game.visible:
		add_player_score()
		ball_timer.start()
		player_point.play()
		get_parent().win_lose()
