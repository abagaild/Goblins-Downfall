extends Area3D
class_name Sun3D

@export var value: int = 25
@export var lifetime: float = 15.0
@export var collect_speed: float = 10.0

var is_being_collected: bool = false
var target_position: Vector3
var timer: float = 0.0

func _ready():
    # Create a simple sun mesh
    var sun_mesh = MeshInstance3D.new()
    var sphere = SphereMesh.new()
    sphere.radius = 0.5
    sphere.height = 1.0
    sun_mesh.mesh = sphere
    
    # Create a glowing material
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(1.0, 0.9, 0.0)  # Golden yellow
    material.emission_enabled = true
    material.emission = Color(1.0, 0.9, 0.0)
    material.emission_energy = 2.0
    sun_mesh.material_override = material
    
    add_child(sun_mesh)
    
    # Create collision shape
    var collision = CollisionShape3D.new()
    var sphere_shape = SphereShape3D.new()
    sphere_shape.radius = 0.6
    collision.shape = sphere_shape
    add_child(collision)
    
    # Add a pulsing animation
    var tween = create_tween()
    tween.set_loops()
    tween.tween_property(sun_mesh, "scale", Vector3(1.1, 1.1, 1.1), 0.5)
    tween.tween_property(sun_mesh, "scale", Vector3(1.0, 1.0, 1.0), 0.5)
    
    # Connect input event
    input_event.connect(_on_input_event)
    
    # Add falling animation
    var fall_tween = create_tween()
    fall_tween.tween_property(self, "position:y", 1.0, 2.0).set_ease(Tween.EASE_OUT)

func _process(delta):
    if is_being_collected:
        # Move toward target position
        var direction = (target_position - position).normalized()
        position += direction * collect_speed * delta
        
        # Check if we've reached the target
        if position.distance_to(target_position) < 0.5:
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
            tween.tween_property(self, "scale", Vector3(0.1, 0.1, 0.1), 1.0)
            tween.tween_callback(queue_free)

func _on_input_event(_camera, event, _position, _normal, _shape_idx):
    # Check for mouse click
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        collect()

func collect():
    is_being_collected = true
    
    # Find the sun counter position to move toward (in 3D space)
    var hud = find_hud()
    if hud:
        # Convert HUD position to 3D world position
        var camera = get_viewport().get_camera_3d()
        if camera:
            var screen_pos = hud.get_sun_counter_position()
            var ray_origin = camera.project_ray_origin(screen_pos)
            var ray_direction = camera.project_ray_normal(screen_pos)
            
            # Use a fixed distance from camera
            target_position = ray_origin + ray_direction * 2.0
        else:
            # Default if no camera
            target_position = Vector3(0, 5, 0)
    else:
        # Default if no HUD
        target_position = Vector3(0, 5, 0)

func find_combat_system():
    # Find the combat system in the scene
    var root = get_tree().root
    var combat_system = root.find_child("PVZCombatSystem3D", true, false)
    return combat_system

func find_hud():
    # Find the HUD in the scene
    var root = get_tree().root
    var hud = root.find_child("CombatHUD3D", true, false)
    return hud