extends Node2D
class_name EnemyBase

# Enemy stats
@export var enemy_name: String = "Enemy"  # Changed from 'name' to avoid conflicts
@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var attack_power: float = 10.0
@export var defense: float = 5.0
@export var is_boss: bool = false

# Attack patterns
var attacks = []
var current_attack = ""

# Visual elements
@export var sprite: Texture2D
@export var animation_player_path: NodePath
var animation_player = null
var sprite_node = null

# Signals
signal health_changed(current, maximum)
signal attack_chosen(attack_name)
signal defeated

func _ready():
	if animation_player_path:
		animation_player = get_node(animation_player_path)
	
	# Create a sprite node if one doesn't exist
	sprite_node = Sprite2D.new()
	add_child(sprite_node)
	
	# Apply the texture if it's set
	if sprite:
		sprite_node.texture = sprite
	
	emit_signal("health_changed", current_health, max_health)
	
	# Initialize basic attacks for all enemies
	if attacks.is_empty():
		attacks = ["basic"]

func take_damage(amount):
	var actual_damage = max(1, amount - defense)
	current_health -= actual_damage
	current_health = max(0, current_health)
	
	emit_signal("health_changed", current_health, max_health)
	
	if animation_player:
		animation_player.play("hit")
	else:
		# Simple hit animation if no animation player
		var tween = create_tween()
		tween.tween_property(sprite_node, "modulate", Color(1, 0, 0), 0.1)
		tween.tween_property(sprite_node, "modulate", Color(1, 1, 1), 0.1)
	
	if current_health <= 0:
		defeat()
	
	return actual_damage

func heal(amount):
	current_health += amount
	current_health = min(current_health, max_health)
	
	emit_signal("health_changed", current_health, max_health)

func choose_attack():
	# Randomly select an attack from available attacks
	current_attack = attacks[randi() % attacks.size()]
	emit_signal("attack_chosen", current_attack)
	
	if animation_player:
		animation_player.play("attack_" + current_attack)
	else:
		# Simple attack animation if no animation player
		var tween = create_tween()
		tween.tween_property(sprite_node, "scale", Vector2(1.2, 1.2), 0.2)
		tween.tween_property(sprite_node, "scale", Vector2(1, 1), 0.2)
	
	return current_attack

func get_bullet_pattern(attack_name):
	# Default implementation - override in specific enemy classes
	return attack_name

func defeat():
	if animation_player:
		animation_player.play("defeat")
		await animation_player.animation_finished
	else:
		# Simple defeat animation if no animation player
		var tween = create_tween()
		tween.tween_property(sprite_node, "modulate", Color(1, 1, 1, 0), 0.5)
		# Wait for the tween to complete
		await tween.finished
	
	emit_signal("defeated")

func _on_health_changed(current, maximum):
	# Update health bar if it exists
	var health_bar = get_node_or_null("HealthBar")
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current
