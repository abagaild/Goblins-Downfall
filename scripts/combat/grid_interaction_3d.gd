extends Node3D
class_name GridInteraction3D

@export var combat_system_path: NodePath
@export var camera_path: NodePath
@export var grid_width: int = 9
@export var grid_height: int = 5
@export var cell_size: Vector3 = Vector3(2.0, 0.0, 2.0)

var combat_system = null
var camera = null
var grid_visual = null
var highlight_material = null
var current_highlight = null

func _ready():
    if combat_system_path:
        combat_system = get_node(combat_system_path)
    
    if camera_path:
        camera = get_node(camera_path)
    
    # Create grid visualization
    create_grid_visual()
    
    # Create highlight material
    highlight_material = StandardMaterial3D.new()
    highlight_material.albedo_color = Color(0.2, 1.0, 0.2, 0.5)
    highlight_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

func _process(_delta):
    # Update grid cell highlighting based on mouse position
    update_grid_highlight()

func _input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        # Get the grid position from the mouse position
        var grid_pos = get_grid_position_from_mouse()
        if grid_pos:
            # Try to place a plant at this position
            if combat_system and combat_system.selected_plant != "":
                combat_system.place_plant(grid_pos.x, grid_pos.y)

func create_grid_visual():
    grid_visual = Node3D.new()
    add_child(grid_visual)
    
    # Create a visual representation of the grid
    var grid_material = StandardMaterial3D.new()
    grid_material.albedo_color = Color(0.8, 0.8, 0.8, 0.2)
    grid_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    
    for z in range(grid_height):
        for x in range(grid_width):
            var cell = MeshInstance3D.new()
            var plane_mesh = PlaneMesh.new()
            plane_mesh.size = Vector2(cell_size.x * 0.9, cell_size.z * 0.9)
            cell.mesh = plane_mesh
            cell.material_override = grid_material
            
            cell.position = Vector3(x * cell_size.x, 0.01, z * cell_size.z)  # Slightly above ground
            grid_visual.add_child(cell)

func update_grid_highlight():
    # Remove previous highlight
    if current_highlight:
        current_highlight.queue_free()
        current_highlight = null
    
    # Get grid position from mouse
    var grid_pos = get_grid_position_from_mouse()
    if grid_pos:
        # Create highlight at grid position
        current_highlight = MeshInstance3D.new()
        var plane_mesh = PlaneMesh.new()
        plane_mesh.size = Vector2(cell_size.x * 0.95, cell_size.z * 0.95)
        current_highlight.mesh = plane_mesh
        current_highlight.material_override = highlight_material
        
        current_highlight.position = Vector3(grid_pos.x * cell_size.x, 0.02, grid_pos.y * cell_size.z)
        add_child(current_highlight)

func get_grid_position_from_mouse():
    # Cast ray from camera to ground plane
    if not camera:
        return null
    
    var mouse_pos = get_viewport().get_mouse_position()
    var ray_origin = camera.project_ray_origin(mouse_pos)
    var ray_direction = camera.project_ray_normal(mouse_pos)
    
    # Define ground plane (y=0)
    var plane = Plane(Vector3(0, 1, 0), 0)
    
    # Intersect ray with plane
    var intersection = plane.intersects_ray(ray_origin, ray_direction)
    if not intersection:
        return null
    
    # Convert to grid coordinates
    var grid_x = int(intersection.x / cell_size.x)
    var grid_z = int(intersection.z / cell_size.z)
    
    # Check if within grid bounds
    if grid_x >= 0 and grid_x < grid_width and grid_z >= 0 and grid_z < grid_height:
        return Vector2(grid_x, grid_z)
    
    return null