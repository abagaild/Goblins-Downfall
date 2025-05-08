extends Area2D
class_name Pea

# Projectile properties
@export var damage: float = 20.0
@export var speed: float = 300.0
var direction: Vector2 = Vector2.RIGHT

# Visual elements
@export var sprite: Texture2D

func _ready():
    # Create a sprite node if one doesn't exist
    var sprite_node = Sprite2D.new()
    add_child(sprite_node)
    
    # Apply the texture if it's set
    if sprite:
        sprite_node.texture = sprite
    
    # Create collision shape
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 5.0
    collision.shape = shape
    add_child(collision)
    
    # Connect signals
    body_entered.connect(_on_body_entered)

func _process(delta):
    # Move in the specified direction
    position += direction * speed * delta
    
    # Destroy if off-screen
    if position.x > 1200:  # Adjust based on your screen size
        queue_free()

func _on_body_entered(body):
    # Check if this is an enemy
    if body is PVZEnemyBase:
        # Apply damage
        body.take_damage(damage)
        
        # Play hit effect
        var hit_effect = create_hit_effect()
        get_parent().add_child(hit_effect)
        hit_effect.global_position = global_position
        
        # Destroy projectile
        queue_free()

func create_hit_effect():
    # Create a simple hit effect
    var effect = Node2D.new()
    
    # Add a sprite
    var sprite_node = Sprite2D.new()
    effect.add_child(sprite_node)
    
    # Create animation
    var tween = effect.create_tween()
    tween.tween_property(sprite_node, "scale", Vector2(1.5, 1.5), 0.2)
    tween.tween_property(sprite_node, "modulate", Color(1, 1, 1, 0), 0.3)
    
    # Queue free after animation
    tween.tween_callback(effect.queue_free)
    
    return effect