extends CharacterBody2D

# ------------------------------
# CONSTANTS
# ------------------------------
const START_SPEED : int = 500      # Initial speed of the ball
const ACCEL : int = 50             # Speed increment per paddle hit
const MAX_Y_VECTOR : float = 0.6   # Limits the vertical angle of the bounce

# ------------------------------
# VARIABLES
# ------------------------------
var win_size : Vector2             # Stores the size of the game window
var speed : int                    # Current speed of the ball
var collisions : int               # Counts number of paddle collisions
var max_speed : int = 200          # Maximum speed increase limit
var dir : Vector2                  # Direction vector of the ball
var disable_e : bool = false       # Prevents multiple ball spawns

# ------------------------------
# NODES
# ------------------------------
@onready var press = $Press        # "Press" UI node

# ------------------------------
# BUILT-IN FUNCTIONS
# ------------------------------

func _ready() -> void:
	win_size = get_viewport_rect().size
	press.visible = true

func _input(_event: InputEvent) -> void:
	# Start ball movement when pressing "interact"
	if Input.is_action_just_pressed("interact") and disable_e == false:
		if Dialogic.current_timeline == null:
			new_ball()
			press.visible = false
			disable_e = true

func _physics_process(delta: float) -> void:
	# Do nothing if the ball node is not visible
	if not is_visible_in_tree():
		return

	# Move the ball and handle collisions
	var collision = move_and_collide(dir * speed * delta)
	if collision:
		var collider = collision.get_collider()
		
		# If collided with a paddle (Player or CPU)
		if collider == $"../Player" or collider == $"../CPU":
			collisions += 1
			
			# Increase speed until reaching max speed
			if collisions <= max_speed:
				speed += ACCEL
			if collisions == max_speed:
				print("MAX SPEED!")
			
			dir = new_direction(collider)
		
		# Bounce off walls
		else:
			dir = dir.bounce(collision.get_normal())

# ------------------------------
# PUBLIC FUNCTIONS
# ------------------------------

# Initializes a new ball with default speed and random direction
func new_ball() -> void:
	speed = START_SPEED
	dir = random_direction()

# Resets ball to center of the screen
func reset_ball() -> void:
	collisions = 0
	position.x = win_size.x / 2
	position.y = randi_range(200, int(win_size.y) - 200)  # Random vertical position
	speed = 0

# ------------------------------
# PRIVATE FUNCTIONS
# ------------------------------

# Returns a random initial direction for the ball
func random_direction() -> Vector2:
	var new_dir := Vector2()
	new_dir.x = [1, -1].pick_random()
	new_dir.y = randf_range(-1, 1)
	return new_dir.normalized()

# Calculates new direction after hitting a paddle
func new_direction(collider) -> Vector2:
	var ball_y = position.y
	var pad_y = collider.position.y
	var dist = ball_y - pad_y
	var new_dir := Vector2()

	# Reverse horizontal direction
	new_dir.x = -1 if dir.x > 0 else 1

	# Adjust vertical direction based on hit position on paddle
	new_dir.y = (dist / (collider.p_height / 2)) * MAX_Y_VECTOR
	return new_dir.normalized()
