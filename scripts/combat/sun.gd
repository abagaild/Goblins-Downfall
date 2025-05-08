extends Area2D
class_name Sun

# Sun properties
@export var value: int = 25
@export var lifetime: float = 10.0  # How long before disappearing
@export var collect_speed: float = 500.0  # Speed when being collected

# Private variables
var timer: float = 0.0
var is_being_collected: bool = false
var target_position: Vector2 = Vector2.ZERO

# Visual elements
@export var sprite: Texture2D
var sprite_node = null

func _ready():
    # Create a sprite node
    sprite_node = Sprite2D.new()
    add_child(sprite_node)
    
    # Apply the texture if it's set
    if sprite:
        sprite_node.texture = sprite
    
    # Create collision shape
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 20.0
    collision.shape = shape
    add_child(collision)
    
    # Connect signals
    input_event.connect(_on_input_event)
    
    # Add a pulsing animation
    var tween = create_tween()
    tween.set_loops()
    tween.tween_property(sprite_node, "scale", Vector2(1.1, 1.1), 0.5)
    tween.tween_property(sprite_node, "scale", Vector2(1.0, 1.0), 0.5)

func _process(delta):
    if is_being_collected:
        # Move toward target position
        var direction = (target_position - position).normalized()
        position += direction * collect_speed * delta
        
        # Check if we've reached the target
        if position.distance_to(target_position) < 10:
            # Add sun to player's total
            var combat_system = find_combat_system()
            if combat_system:
                combat_system.add_sun(value)
            queue_free()
    else:
        # Count down lifetime
        timer += delta
        if timer >= lifetime:
            # Fade out and disappear
            var tween = create_tween()
            tween.tween_property(sprite_node, "modulate", Color(1, 1, 1, 0), 1.0)
            tween.tween_callback(queue_free)

func _on_input_event(_viewport, event, _shape_idx):
    # Check for mouse click
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        collect()

func collect():
    is_being_collected = true
    
    # Find the sun counter position to move toward
    var hud = find_hud()
    if hud:
        target_position = hud.get_sun_counter_position()
    else:
        # Default to top-right corner if HUD not found
        target_position = Vector2(1000, 50)

func find_combat_system():
    # Find the combat system in the scene
    var root = get_tree().root
    var combat_system = root.find_child("PVZCombatSystem", true, false)
    return combat_system

func find_hud():
    # Find the HUD in the scene
    var root = get_tree().root
    var hud = root.find_child("CombatHUD", true, false)
    return hud