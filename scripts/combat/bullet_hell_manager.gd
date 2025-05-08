extends Node2D
class_name BulletHellManager

# References
@export var player_dodge_area_path: NodePath
@export var bullet_container_path: NodePath
@export var combat_system_path: NodePath

# Private variables
var player_dodge_area = null
var bullet_container = null
var combat_system = null
var active_pattern = null
var pattern_duration = 5.0
var timer = 0.0
var damage_taken = 0
var is_active = false

# Bullet patterns
var bullet_patterns = {
    "basic": {
        "bullet_speed": 150,
        "spawn_rate": 0.5,
        "duration": 5.0,
        "bullet_type": "regular"
    },
    "rapid": {
        "bullet_speed": 200,
        "spawn_rate": 0.2,
        "duration": 5.0,
        "bullet_type": "small"
    },
    "spiral": {
        "bullet_speed": 120,
        "spawn_rate": 0.1,
        "duration": 7.0,
        "bullet_type": "spiral"
    },
    "psychosis": {
        "bullet_speed": 180,
        "spawn_rate": 0.15,
        "duration": 10.0,
        "bullet_type": "hallucination"
    },
    "mania": {
        "bullet_speed": 250,
        "spawn_rate": 0.1,
        "duration": 8.0,
        "bullet_type": "erratic"
    },
    "ocd": {
        "bullet_speed": 130,
        "spawn_rate": 0.3,
        "duration": 12.0,
        "bullet_type": "pattern"
    },
    "ptsd": {
        "bullet_speed": 200,
        "spawn_rate": 0.4,
        "duration": 9.0,
        "bullet_type": "flashback"
    },
    "depression": {
        "bullet_speed": 100,
        "spawn_rate": 0.5,
        "duration": 15.0,
        "bullet_type": "heavy"
    }
}

func _ready():
    if player_dodge_area_path:
        player_dodge_area = get_node(player_dodge_area_path)
    
    if bullet_container_path:
        bullet_container = get_node(bullet_container_path)
    
    if combat_system_path:
        combat_system = get_node(combat_system_path)
        combat_system.connect("dodge_phase_started", Callable(self, "start_bullet_pattern"))

func _process(delta):
    if not is_active:
        return
    
    timer += delta
    
    # Spawn bullets based on active pattern
    if active_pattern:
        if timer >= active_pattern.spawn_rate:
            spawn_bullet(active_pattern.bullet_type)
            timer = 0
        
        # End pattern after duration
        if timer >= active_pattern.duration:
            end_bullet_pattern()

func start_bullet_pattern(pattern_name):
    if not bullet_patterns.has(pattern_name):
        pattern_name = "basic"
    
    active_pattern = bullet_patterns[pattern_name]
    pattern_duration = active_pattern.duration
    timer = 0
    damage_taken = 0
    is_active = true
    
    # Clear any existing bullets
    for bullet in bullet_container.get_children():
        bullet.queue_free()

func spawn_bullet(bullet_type):
    # Create a simple bullet node instead of loading a scene
    var bullet = create_bullet_node()
    bullet_container.add_child(bullet)
    
    # Set bullet properties based on type
    match bullet_type:
        "regular":
            setup_bullet(bullet, active_pattern.bullet_speed, Vector2.DOWN.rotated(randf_range(-0.5, 0.5)))
        "small":
            setup_bullet(bullet, active_pattern.bullet_speed, Vector2.DOWN.rotated(randf_range(-0.8, 0.8)), 0.5)
        "spiral":
            var angle = timer * 5
            setup_bullet(bullet, active_pattern.bullet_speed, Vector2.RIGHT.rotated(angle))
        "hallucination":
            # Some bullets are fake and pass through player
            setup_bullet(bullet, active_pattern.bullet_speed, Vector2.DOWN.rotated(randf_range(-1, 1)), 1.0, randf() > 0.5)
        "erratic":
            setup_bullet(bullet, active_pattern.bullet_speed, Vector2.DOWN.rotated(randf_range(-PI, PI)), 1.0, false, true)
        "pattern":
            # Create patterns of bullets in geometric shapes
            for i in range(8):
                var angle = i * PI / 4
                var b = create_bullet_node()
                bullet_container.add_child(b)
                setup_bullet(b, active_pattern.bullet_speed, Vector2.RIGHT.rotated(angle))
        "flashback":
            # Bullets that appear suddenly close to player
            var player_pos = player_dodge_area.global_position
            bullet.global_position = player_pos + Vector2(randf_range(-100, 100), randf_range(-100, 100))
            setup_bullet(bullet, active_pattern.bullet_speed, (player_pos - bullet.global_position).normalized())
        "heavy":
            # Slow but large and damaging bullets
            setup_bullet(bullet, active_pattern.bullet_speed, Vector2.DOWN, 2.0, false, false, 2.0)

# Create a simple bullet node
func create_bullet_node():
    var bullet = Area2D.new()
    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    var sprite = Sprite2D.new()
    
    shape.radius = 8
    collision.shape = shape
    bullet.add_child(collision)
    bullet.add_child(sprite)
    
    # Connect signals
    bullet.body_entered.connect(func(body): on_bullet_hit(bullet, body))
    
    return bullet

# Setup bullet properties
func setup_bullet(bullet, speed, direction, scale_factor = 1.0, is_fake = false, is_erratic = false, damage_mult = 1.0):
    bullet.scale = Vector2(scale_factor, scale_factor)
    
    # Store properties in metadata
    bullet.set_meta("speed", speed)
    bullet.set_meta("direction", direction)
    bullet.set_meta("is_fake", is_fake)
    bullet.set_meta("is_erratic", is_erratic)
    bullet.set_meta("damage_mult", damage_mult)
    
    # Add a script to handle movement
    var script = GDScript.new()
    script.source_code = """
    extends Area2D
    
    func _process(delta):
        var speed = get_meta("speed")
        var direction = get_meta("direction")
        var is_erratic = get_meta("is_erratic")
        
        if is_erratic:
            direction = direction.rotated(randf_range(-0.2, 0.2))
        
        position += direction * speed * delta
        
        # Remove if out of screen
        var viewport_rect = get_viewport_rect()
        if not viewport_rect.has_point(global_position):
            queue_free()
    """
    script.reload()
    bullet.set_script(script)

func end_bullet_pattern():
    is_active = false
    
    # Clear any remaining bullets
    for bullet in bullet_container.get_children():
        bullet.queue_free()
    
    # Notify combat system
    combat_system.dodge_phase_completed(damage_taken)

func on_bullet_hit(bullet, body):
    if body == player_dodge_area:
        if not bullet.get_meta("is_fake"):
            var damage = 10 * bullet.get_meta("damage_mult")
            damage_taken += damage
        bullet.queue_free()