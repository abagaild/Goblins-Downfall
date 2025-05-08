extends Camera2D

# Camera settings
@export var target_path: NodePath
@export var camera_speed: float = 5.0
@export var zoom_level: float = 1.0
@export var screen_shake_decay: float = 5.0
@export var max_offset: float = 10.0

# Private variables
var target = null
var shake_strength: float = 0.0
var rng = RandomNumberGenerator.new()

func _ready():
	# Get the target node (usually the player)
	if target_path:
		target = get_node(target_path)
	
	# Set initial zoom
	zoom = Vector2(zoom_level, zoom_level)
	
	# Initialize random number generator
	rng.randomize()

func _process(delta):
	if target:
		# Smoothly move camera to follow target
		global_position = global_position.lerp(target.global_position, camera_speed * delta)
	
	# Handle screen shake
	if shake_strength > 0:
		# Apply random offset based on shake strength
		offset = Vector2(
			rng.randf_range(-shake_strength, shake_strength),
			rng.randf_range(-shake_strength, shake_strength)
		)
		
		# Decay the shake strength over time
		shake_strength = max(0, shake_strength - screen_shake_decay * delta)
	else:
		# Reset offset when not shaking
		offset = Vector2.ZERO

func set_target(new_target):
	target = new_target

func set_zoom(new_zoom):
	zoom_level = new_zoom
	zoom = Vector2(zoom_level, zoom_level)

func shake_screen(strength, duration):
	# Set shake strength
	shake_strength = min(strength, max_offset)
	
	# Reset shake after duration
	get_tree().create_timer(duration).timeout.connect(func(): shake_strength = 0)
