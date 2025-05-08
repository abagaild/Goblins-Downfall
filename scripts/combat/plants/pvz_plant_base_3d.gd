extends Node3D
class_name PVZPlantBase3D

# Plant stats
@export var plant_name: String = "Basic Plant"
@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var sun_cost: int = 100

# Visual elements
@export var model_path: String = ""
@export var animation_player_path: NodePath
var animation_player = null
var model_node = null

# Signals
signal plant_destroyed
signal health_changed(current, maximum)

func _ready():
    if animation_player_path:
        animation_player = get_node(animation_player_path)
    
    # Load 3D model if specified
    if model_path and model_path != "":
        var model_scene = load(model_path)
        if model_scene:
            model_node = model_scene.instantiate()
            add_child(model_node)
    
    current_health = max_health
    emit_signal("health_changed", current_health, max_health)
    
    # Create health indicator in 3D space
    create_health_indicator()

func create_health_indicator():
    # Create a simple health bar using a 3D quad with shader
    var health_bar = MeshInstance3D.new()
    var quad_mesh = QuadMesh.new()
    quad_mesh.size = Vector2(1.0, 0.1)
    health_bar.mesh = quad_mesh
    
    # Position above the plant
    health_bar.position = Vector3(0, 1.5, 0)
    # Make it face the camera
    health_bar.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    
    add_child(health_bar)
    
    # Create material for health display
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(0, 1, 0)  # Green for health
    material.emission_enabled = true
    material.emission = Color(0, 1, 0)
    health_bar.material_override = material

func take_damage(amount):
    current_health -= amount
    current_health = max(0, current_health)
    
    emit_signal("health_changed", current_health, max_health)
    
    # Update health bar visual
    update_health_visual()
    
    if animation_player:
        animation_player.play("hit")
    
    if current_health <= 0:
        destroy()
    
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
            material.albedo_color = Color(0, 1, 0)  # Green
        elif health_percent > 0.3:
            material.albedo_color = Color(1, 1, 0)  # Yellow
        else:
            material.albedo_color = Color(1, 0, 0)  # Red

func destroy():
    if animation_player:
        animation_player.play("destroy")
        await animation_player.animation_finished
    else:
        # Simple destroy animation
        var tween = create_tween()
        tween.tween_property(self, "scale", Vector3(0.1, 0.1, 0.1), 0.5)
        await tween.finished
    
    emit_signal("plant_destroyed", self)
    queue_free()