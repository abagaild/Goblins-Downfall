extends CharacterBody3D
class_name EnemyBase3D

# Enemy stats
@export var enemy_name: String = "Basic Goblin"
@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var move_speed: float = 0.5
@export var attack_damage: float = 10.0
@export var attack_interval: float = 1.0

# Movement
@export var lane: int = 0
var target_x: float = 0.0
var is_attacking: bool = false
var attack_timer: float = 0.0

# References
@export var animation_player_path: NodePath
var animation_player = null

# Signals
signal enemy_defeated
signal reached_end
signal health_changed(current, maximum)

func _ready():
    if animation_player_path:
        animation_player = get_node(animation_player_path)
    
    current_health = max_health
    emit_signal("health_changed", current_health, max_health)
    
    # Create health indicator
    create_health_indicator()
    
    # Start walking animation
    if animation_player:
        animation_player.play("walk")

func _physics_process(delta):
    if is_attacking:
        # Handle attack timing
        attack_timer += delta
        if attack_timer >= attack_interval:
            perform_attack()
            attack_timer = 0.0
    else:
        # Move forward (toward negative X in 3D space)
        velocity = Vector3(-move_speed, 0, 0)
        move_and_slide()
        
        # Check if reached the end of the lane
        if position.x <= 0:
            emit_signal("reached_end")
            queue_free()

func create_health_indicator():
    # Create a simple health bar using a 3D quad with shader
    var health_bar = MeshInstance3D.new()
    var quad_mesh = QuadMesh.new()
    quad_mesh.size = Vector2(1.0, 0.1)
    health_bar.mesh = quad_mesh
    health_bar.name = "HealthBar"
    
    # Position above the enemy
    health_bar.position = Vector3(0, 1.5, 0)
    # Make it face the camera
    health_bar.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    
    add_child(health_bar)
    
    # Create material for health display
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(1, 0, 0)  # Red for enemy health
    material.emission_enabled = true
    material.emission = Color(1, 0, 0)
    health_bar.material_override = material

func take_damage(amount):
    current_health -= amount
    current_health = max(0, current_health)
    
    emit_signal("health_changed", current_health, max_health)
    
    # Update health bar visual
    update_health_visual()
    
    if animation_player:
        animation_player.play("hit")
        await animation_player.animation_finished
        if current_health > 0:
            animation_player.play("walk")
    
    if current_health <= 0:
        defeat()
    
    return amount

func update_health_visual():
    # Update the health bar material
    if has_node("HealthBar"):
        var health_bar = get_node("HealthBar")
        var health_percent = current_health / max_health
        
        # Scale the quad to represent health
        health_bar.mesh.size.x = health_percent
        
        # Change color based on health
        var material = health_bar.material_override
        if health_percent > 0.6:
            material.albedo_color = Color(1, 0, 0)  # Red
        elif health_percent > 0.3:
            material.albedo_color = Color(1, 0.5, 0)  # Orange
        else:
            material.albedo_color = Color(0.5, 0, 0)  # Dark red

func start_attacking(plant):
    is_attacking = true
    attack_timer = 0.0
    
    if animation_player:
        animation_player.play("attack")

func perform_attack():
    # Find plant in front
    var space_state = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D