extends PVZPlantBase
class_name Peashooter

# Attack properties
@export var damage: float = 20.0
@export var attack_interval: float = 1.5
@export var projectile_speed: float = 300.0

# Private variables
var attack_timer: float = 0.0
var enemies_in_lane = []

func _ready():
    super._ready()
    
    # Set plant-specific properties
    plant_name = "Peashooter"
    max_health = 100.0
    current_health = max_health
    sun_cost = 100

func _process(delta):
    # Check for enemies in lane
    if enemies_in_lane.size() > 0:
        # Handle attack cooldown
        attack_timer += delta
        if attack_timer >= attack_interval:
            shoot()
            attack_timer = 0.0

func shoot():
    # Play shooting animation
    if animation_player:
        animation_player.play("shoot")
    
    # Create projectile
    var projectile = preload("res://scenes/combat/projectiles/pea.tscn").instantiate()
    get_parent().add_child(projectile)
    
    # Set projectile properties
    projectile.position = global_position + Vector2(30, 0)  # Offset from plant center
    projectile.damage = damage
    projectile.speed = projectile_speed
    projectile.direction = Vector2.RIGHT

func _on_detection_area_body_entered(body):
    # Check if this is an enemy
    if body is PVZEnemyBase:
        enemies_in_lane.append(body)

func _on_detection_area_body_exited(body):
    # Remove from tracked enemies
    if body in enemies_in_lane:
        enemies_in_lane.erase(body)