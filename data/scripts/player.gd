extends CharacterBody2D

# Screen dimensions
var win_width: float   # Width of the game window
var win_height: float  # Height of the game window

# Paddle sprite dimensions (adjusted with scale)
var p_width: float   # Paddle width
var p_height: float  # Paddle height

# Control states
@export var glitched = false   # If true, paddle can also move horizontally
@export var enable = true      # If true, player input is enabled

func _ready() -> void:
	# Get the size of the viewport (game window)
	var viewport_size = get_viewport_rect().size
	win_width = viewport_size.x   # Store window width
	win_height = viewport_size.y  # Store window height

	# Calculate paddle dimensions based on the texture size and scale
	p_width = $Sprite2D.texture.get_size().x * $Sprite2D.scale.x
	p_height = $Sprite2D.texture.get_size().y * $Sprite2D.scale.y

func _process(delta: float) -> void:
	if enable:
		# Keep paddle inside the screen bounds
		# Clamping ensures it never goes off-screen
		position.y = clamp(position.y, p_height * 0.5, win_height - (p_height * 0.5))
		position.x = clamp(position.x, p_width * 0.5, win_width - (p_width * 0.5))
		
		# Try to get the paddle speed from the parent node
		var paddle_speed = get_parent().get("PADDLE_SPEED") if get_parent().has_method("get") else null
		if paddle_speed == null:
			return  # Prevents errors if PADDLE_SPEED does not exist

		# Vertical movement (normal behavior)
		if Input.is_action_pressed("move_up"):
			position.y -= paddle_speed * delta  # Move up
		if Input.is_action_pressed("move_down"):
			position.y += paddle_speed * delta  # Move down

		# Extra horizontal movement (only when glitched mode is active)
		if glitched:
			if Input.is_action_pressed("move_right"):
				position.x += paddle_speed * delta  # Move right
			if Input.is_action_pressed("move_left"):
				position.x -= paddle_speed * delta  # Move left

	if not enable:
		# If input is disabled, do nothing
		pass
