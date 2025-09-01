extends CharacterBody2D

# Variables related to ball tracking and AI movement
var ball_pos: Vector2              # Current position of the ball
var dist: float                    # Distance between paddle and ball (on the y-axis)
var move_by: float                 # Amount to move in the current frame
var win_height: float              # Screen height
var win_width: float               # Width of the game window
var p_height: float                # Paddle height adjusted by scale
var p_width: float                 # Paddle width
var reaction_delay: float          # AI delay in seconds before reacting to the ball
var time_since_update: float = 0.0 # Elapsed time since the last target position update
var target_pos: Vector2            # Target position that the paddle aims to move towards

@export var enable = true          # If false, paddle is disabled and hidden
@export var playable = false       # If true, can be playable
@export var glitched = false       # If true, paddle can also move horizontally

func _ready() -> void:
	var viewport_size = get_viewport_rect().size
	win_width = viewport_size.x   # Store window width
	win_height = viewport_size.y  # Store window height

	# Calculate paddle dimensions based on the texture size and scale
	p_width = $Sprite2D.texture.get_size().x * $Sprite2D.scale.x
	p_height = $Sprite2D.texture.get_size().y * $Sprite2D.scale.y
	
	# Initialize target position with the paddle’s initial position
	target_pos = position  

func _process(delta: float) -> void:
	if enable:
		# Keep the paddle within the screen bounds
		position.y = clamp(position.y, p_height * 0.5, win_height - (p_height * 0.5))
		position.x = clamp(position.x, p_width * 0.5, win_width - (p_width * 0.5))
		
		if not playable:
			# Safely get the ball node from the scene
			var ball = get_parent().get_node_or_null("Ball")  
			if not ball:
				return  # If the ball does not exist, exit
			
			# Update target position with a reaction delay
			time_since_update += delta
			if time_since_update >= reaction_delay:
				target_pos = ball.position  # AI updates its target position to follow the ball
				time_since_update = 0.0     # Reset timer
			
			# Calculate distance from current paddle position to target position
			dist = position.y - target_pos.y

			# Get paddle speed safely from parent
			var paddle_speed = get_parent().get("PADDLE_SPEED") if get_parent().has_method("get") else null
			if paddle_speed == null:
				return  # Prevent errors if the variable does not exist

			# Determine movement amount based on paddle speed and distance
			if abs(dist) > paddle_speed * delta:
				move_by = paddle_speed * delta * sign(dist)  
				# sign(dist) ensures correct direction (up or down) 
			else:
				move_by = dist  # Move directly if distance is small enough

			# Apply movement
			position.y -= move_by  
			
		if playable:
			# Try to get the paddle speed from the parent node
			var paddle_speed = get_parent().get("PADDLE_SPEED") if get_parent().has_method("get") else null
			if paddle_speed == null:
				return  # Prevents errors if PADDLE_SPEED does not exist

			# Vertical movement (normal behavior)
			if Input.is_action_pressed("ui_up"):
				position.y -= paddle_speed * delta  # Move up
			if Input.is_action_pressed("ui_down"):
				position.y += paddle_speed * delta  # Move down
				
			# Extra horizontal movement (only when glitched mode is active)
			if glitched:
				if Input.is_action_pressed("ui_right"):
					position.x += paddle_speed * delta  # Move right
				if Input.is_action_pressed("ui_left"):
					position.x -= paddle_speed * delta  # Move left

	else:
		# Disable paddle visibility and collisions if "enable" is false
		self.visible = false
		$CollisionShape2D.disabled = true
		$CollisionShape2D2.disabled = true
