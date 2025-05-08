extends Node2D

# References
@export var combat_system_path: NodePath
var combat_system = null

# Grid properties
var cell_size = Vector2(100, 100)
var grid_width = 9
var grid_height = 5
var grid_offset = Vector2(100, 150)  # Offset from top-left of screen

func _ready():
    # Get combat system reference
    if combat_system_path:
        combat_system = get_node(combat_system_path)
    else:
        # Try to find it in the scene
        combat_system = get_parent().get_node("CombatSystem")
    
    if combat_system:
        # Get grid properties from combat system
        cell_size = combat_system.cell_size
        grid_width = combat_system.grid_width
        grid_height = combat_system.grid_height
    
    # Draw grid lines for visual reference
    draw_grid_lines()

func _input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        # Convert mouse position to grid coordinates
        var grid_pos = get_grid_position(event.position)
        
        # Check if position is valid
        if grid_pos.x >= 0 and grid_pos.x < grid_width and grid_pos.y >= 0 and grid_pos.y < grid_height:
            # Try to place a plant at this position
            if combat_system and combat_system.selected_plant != "":
                combat_system.place_plant(grid_pos.x, grid_pos.y)

func get_grid_position(screen_position):
    # Convert screen position to grid coordinates
    var local_position = screen_position - grid_offset
    var grid_x = int(local_position.x / cell_size.x)
    var grid_y = int(local_position.y / cell_size.y)
    
    return Vector2(grid_x, grid_y)

func draw_grid_lines():
    # Create a new node for grid lines
    var grid_lines = get_parent().get_node("GridLines")
    
    # Clear any existing lines
    for child in grid_lines.get_children():
        child.queue_free()
    
    # Draw horizontal lines
    for y in range(grid_height + 1):
        var line = Line2D.new()
        line.width = 2.0
        line.default_color = Color(0.5, 0.5, 0.5, 0.5)
        line.add_point(Vector2(grid_offset.x, grid_offset.y + y * cell_size.y))
        line.add_point(Vector2(grid_offset.x + grid_width * cell_size.x, grid_offset.y + y * cell_size.y))
        grid_lines.add_child(line)
    
    # Draw vertical lines
    for x in range(grid_width + 1):
        var line = Line2D.new()
        line.width = 2.0
        line.default_color = Color(0.5, 0.5, 0.5, 0.5)
        line.add_point(Vector2(grid_offset.x + x * cell_size.x, grid_offset.y))
        line.add_point(Vector2(grid_offset.x + x * cell_size.x, grid_offset.y + grid_height * cell_size.y))
        grid_lines.add_child(line)