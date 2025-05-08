extends PVZEnemyBase
class_name BasicZombie

func _ready():
    super._ready()
    
    # Set zombie-specific properties
    enemy_name = "Basic Zombie"
    max_health = 100.0
    current_health = max_health
    movement_speed = 15.0
    damage = 10.0
    attack_interval = 1.0
    
    # Set up collision detection
    var area = Area2D.new()
    add_child(area)
    
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(40, 80)
    collision.shape = shape
    area.add_child(collision)
    
    # Connect signals
    area.area_entered.connect(_on_area_entered)
    area.area_exited.connect(_on_area_exited)