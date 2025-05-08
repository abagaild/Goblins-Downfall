extends Node2D
class_name PVZPlantBase

# Plant stats
@export var plant_name: String = "Basic Plant"
@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var sun_cost: int = 100

# Visual elements
@export var sprite: Texture2D
@export var animation_player_path: NodePath
var animation_player = null
var sprite_node = null

# Signals
signal plant_destroyed
signal health_changed(current, maximum)

func _ready():
    if animation_player_path:
        animation_player = get_node(animation_player_path)
    
    # Create a sprite node if one doesn't exist
    sprite_node = Sprite2D.new()
    add_child(sprite_node)
    
    # Apply the texture if it's set
    if sprite:
        sprite_node.texture = sprite
    
    current_health = max_health
    emit_signal("health_changed", current_health, max_health)

func take_damage(amount):
    current_health -= amount
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
        destroy()
    
    return amount

func destroy():
    if animation_player:
        animation_player.play("destroy")
        await animation_player.animation_finished
    else:
        # Simple destroy animation if no animation player
        var tween = create_tween()
        tween.tween_property(sprite_node, "modulate", Color(1, 1, 1, 0), 0.5)
        await tween.finished
    
    emit_signal("plant_destroyed", self)
    queue_free()