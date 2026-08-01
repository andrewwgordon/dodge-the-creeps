extends Area2D

# Signal emitted when the player collides with an enemy or hazard.
signal hit

# Movement speed of the player in pixels per second.
@export var speed = 400

# Stores the size of the game window so the player can be kept on screen.
var screen_size


# Called when the node enters the scene tree for the first time.
# This runs once when the game starts or when the player is added to the scene.
func _ready() -> void:
	# Get the size of the current viewport (game window).
	screen_size = get_viewport_rect().size

	# Hide the player initially.
	# The player will be shown later when a new game starts.
	hide()


# Called every frame.
# delta is the elapsed time (in seconds) since the previous frame.
# Used here to handle player movement and animation updates.
func _process(delta: float) -> void:
	# Create a movement vector with no direction initially.
	var velocity = Vector2.ZERO

	# Check player input and build movement direction.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1

	if Input.is_action_pressed("move_left"):
		velocity.x -= 1

	if Input.is_action_pressed("move_down"):
		velocity.y += 1

	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	# If the player is moving...
	if velocity.length() > 0:
		# Normalize the vector to prevent faster diagonal movement,
		# then multiply by the configured speed.
		velocity = velocity.normalized() * speed

		# Play the current animation.
		$AnimatedSprite2D.play()
		
		# Play the move sound
		if !$PlayerMove.playing:
			$PlayerMove.play()
	else:
		# Stop animation when the player is not moving.
		$AnimatedSprite2D.stop()

	# Move the player based on velocity and frame time.
	position += velocity * delta

	# Prevent the player from leaving the screen boundaries.
	position = position.clamp(Vector2.ZERO, screen_size)

	# Update sprite animation and orientation based on movement direction.
	if velocity.x != 0:
		# Use walking animation when moving horizontally.
		$AnimatedSprite2D.animation = "walk"

		# Ensure sprite is not flipped vertically.
		$AnimatedSprite2D.flip_v = false

		# Flip horizontally when moving left.
		$AnimatedSprite2D.flip_h = velocity.x < 0

	elif velocity.y != 0:
		# Use up/down animation when moving vertically.
		$AnimatedSprite2D.animation = "up"

		# Flip vertically when moving downward.
		# When moving upward, sprite remains in its default orientation.
		$AnimatedSprite2D.flip_v = velocity.y > 0


# Called automatically when another PhysicsBody2D enters this Area2D.
# Typically used to detect collisions with enemies.
func _on_body_entered(body: Node2D) -> void:
	# Hide the player when hit.
	hide()

	# Notify other nodes (such as Game or HUD) that the player was hit.
	hit.emit()

	# Disable collision safely after the current physics frame.
	# set_deferred() prevents errors from modifying collision states
	# during collision processing.
	$CollisionShape2D.set_deferred("disabled", true)


# Resets and activates the player at the start of a new game.
# pos: The starting position where the player should appear.
func start(pos):
	# Move the player to the starting location.
	position = pos

	# Make the player visible.
	show()

	# Re-enable collision detection.
	$CollisionShape2D.disabled = false
