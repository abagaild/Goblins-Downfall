extends CharacterBody2D

# Player stats
@export var max_fortitude: float = 100.0  # Health
@export var max_resilience: float = 100.0  # Mana
@export var move_speed: float = 200.0
@export var acceleration: float = 1500.0
@export var friction: float = 600.0

# Current stats
var current_fortitude: float
var current_resilience: float
var is_attacking: bool = false

# Signals
signal fortitude_changed(current, maximum)
signal resilience_changed(current, maximum)
signal player_died

func _ready():
	# Initialize stats
	current_fortitude = max_fortitude
	current_resilience = max_resilience
	
	# Emit initial signals for UI
	emit_signal("fortitude_changed", current_fortitude, max_fortitude)
	emit_signal("resilience_changed", current_resilience, max_resilience)

func _physics_process(delta):
	# Handle movement
	var input_direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	
	# Normalize input for consistent diagonal movement
	if input_direction.length() > 1.0:
		input_direction = input_direction.normalized()
	
	# Apply acceleration and friction
	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(input_direction * move_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# Move the character
	move_and_slide()
	
	# Handle animations
	update_animation(input_direction)
	
	# Handle attack input
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

func update_animation(direction):
	# This will be expanded when we have animations
	if direction != Vector2.ZERO:
		# Set facing direction for animations
		$Sprite2D.flip_h = direction.x < 0
	
	# Animation states will be implemented later

func attack():
	# Basic attack implementation
	is_attacking = true
	
	# Play attack animation
	# $AnimationPlayer.play("attack")
	
	# Use some resilience for the attack
	use_resilience(10.0)
	
	# Create attack hitbox
	# This will be expanded later
	
	# Reset attack state after animation
	await get_tree().create_timer(0.5).timeout
	is_attacking = false

func take_damage(amount):
	current_fortitude -= amount
	current_fortitude = max(0, current_fortitude)
	
	emit_signal("fortitude_changed", current_fortitude, max_fortitude)
	
	if current_fortitude <= 0:
		die()

func heal(amount):
	current_fortitude += amount
	current_fortitude = min(current_fortitude, max_fortitude)
	
	emit_signal("fortitude_changed", current_fortitude, max_fortitude)

func use_resilience(amount):
	current_resilience -= amount
	current_resilience = max(0, current_resilience)
	
	emit_signal("resilience_changed", current_resilience, max_resilience)

func restore_resilience(amount):
	current_resilience += amount
	current_resilience = min(current_resilience, max_resilience)
	
	emit_signal("resilience_changed", current_resilience, max_resilience)

func die():
	# Handle player death
	emit_signal("player_died")
	# Disable controls
	set_physics_process(false)
	# Play death animation
	# $AnimationPlayer.play("death")
