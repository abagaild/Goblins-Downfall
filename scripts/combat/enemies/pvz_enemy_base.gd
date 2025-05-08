extends CharacterBody2D
class_name PVZEnemyBase

# Enemy properties
@export var enemy_name: String = "Enemy"
@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var movement_speed: float = 20.0
@export var damage: float = 10.0
@export var attack_interval: float = 1.0
@export var animation_player_path: NodePath
@export var sprite: Texture2D

# State variables
var lane: int = 0
var is_attacking: bool = false
var attack_timer: float = 0.0
var current_target = null
var is_defeated: bool = false

# References
var animation_player = null

# Signals
signal enemy_defeated(enemy)
signal reached_end(enemy)
signal health_changed(current, maximum)

func _ready():
    # Set up animation player
    if animation_player_path:
        animation_player = get_node(animation_player_path)
    
    # Set up sprite if provided
    if sprite and has_node("Sprite2D"):
        $Sprite2D.texture = sprite
    
    # Set up health bar
    if has_node("HealthBar"):
        $HealthBar.max_value = max_health
        $HealthBar.value = current_health
    
    # Emit initial health
    emit_signal("health_changed", current_health, max_health)

func _process(delta):
    if is_defeated:
        return
    
    if is_attacking:
        # Handle attack timing
        attack_timer += delta
        if attack_timer >= attack_interval:
            attack()
            attack_timer = 0.0
    else:
        # Move toward the left (toward the house)
        velocity = Vector2(-movement_speed, 0)
        move_and_slide()
        
        # Check if reached the end (left side of screen)
        if global_position.x <= 100:  # Adjust based on your grid offset
            emit_signal("reached_end", self)
            queue_free()

func take_damage(amount):
    if is_defeated:
        return
    
    current_health -= amount
    emit_signal("health_changed", current_health, max_health)
    
    # Update health bar
    if has_node("HealthBar"):
        $HealthBar.value = current_health
    
    # Check if defeated
    if current_health <= 0:
        defeat()

func attack():
    if is_defeated or not current_target:
        return
    
    # Play attack animation if available
    if animation_player and animation_player.has_animation("attack"):
        animation_player.play("attack")
    
    # Deal damage to target
    if current_target.has_method("take_damage"):
        current_target.take_damage(damage)

func defeat():
    is_defeated = true
    
    # Play defeat animation if available
    if animation_player and animation_player.has_animation("defeat"):
        animation_player.play("defeat")
        # Wait for animation to finish before removing
        await animation_player.animation_finished
    
    emit_signal("enemy_defeated", self)
    queue_free()

func _on_area_entered(area):
    # If we collide with a plant, start attacking
    if area.get_parent() is Node2D and not is_attacking:
        current_target = area.get_parent()
        is_attacking = true
        attack_timer = 0.0

func _on_area_exited(area):
    # If the plant we were attacking is gone, resume movement
    if area.get_parent() == current_target:
        current_target = null
        is_attacking = false

func _on_health_changed(current, maximum):
    # Update health bar
    if has_node("HealthBar"):
        $HealthBar.value = current
