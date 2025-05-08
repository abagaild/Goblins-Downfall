extends PVZPlantBase
class_name Sunflower

# Sun production properties
@export var sun_production: int = 25
@export var production_interval: float = 24.0

# Private variables
var production_timer: float = 0.0

func _ready():
    super._ready()
    
    # Set plant-specific properties
    plant_name = "Sunflower"
    max_health = 50.0
    current_health = max_health
    sun_cost = 50

func _process(delta):
    # Handle sun production
    production_timer += delta
    if production_timer >= production_interval:
        produce_sun()
        production_timer = 0.0

func produce_sun():
    # Play animation
    if animation_player:
        animation_player.play("produce")
    
    # Create sun object
    var sun = preload("res://scenes/combat/sun.tscn").instantiate()
    get_parent().add_child(sun)
    
    # Set sun properties
    sun.position = global_position
    sun.value = sun_production
    
    # Create a small bounce effect
    var tween = create_tween()
    tween.tween_property(sun, "position", global_position + Vector2(0, -50), 0.5)
    tween.tween_property(sun, "position", global_position, 0.3)