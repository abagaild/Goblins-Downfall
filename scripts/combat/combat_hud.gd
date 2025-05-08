extends CanvasLayer
class_name CombatHUD

# References
@export var combat_system_path: NodePath
var combat_system = null

# UI elements
var sun_counter_label = null
var plant_buttons = []
var wave_label = null

# Plant types
var available_plants = ["sunflower", "peashooter", "wallnut"]

func _ready():
    # Get combat system reference
    if combat_system_path:
        combat_system = get_node(combat_system_path)
        
        # Connect signals
        combat_system.connect("sun_changed", Callable(self, "_on_sun_changed"))
        combat_system.connect("wave_started", Callable(self, "_on_wave_started"))
        combat_system.connect("wave_completed", Callable(self, "_on_wave_completed"))
        combat_system.connect("game_over", Callable(self, "_on_game_over"))
    
    # Initialize UI elements
    sun_counter_label = $SunCounter/SunLabel
    wave_label = $WaveLabel
    
    # Create plant buttons
    var plant_panel = $PlantPanel
    
    # Clear any existing buttons
    for child in plant_panel.get_children():
        child.queue_free()
    
    # Create buttons for each plant type
    for plant_type in available_plants:
        var button = Button.new()
        button.text = plant_type.capitalize()
        button.custom_minimum_size = Vector2(100, 70)
        plant_panel.add_child(button)
        
        # Connect button press
        button.pressed.connect(func(): _on_plant_selected(plant_type))
        
        plant_buttons.append(button)
    
    # Update button availability
    if combat_system:
        _on_sun_changed(combat_system.current_sun)

func _on_sun_changed(amount):
    sun_counter_label.text = str(amount)
    
    # Update plant button availability
    for i in range(plant_buttons.size()):
        var plant_type = available_plants[i]
        var plant_data = combat_system.get_plant_data(plant_type)
        
        if plant_data and amount >= plant_data.sun_cost:
            plant_buttons[i].disabled = false
        else:
            plant_buttons[i].disabled = true

func _on_plant_selected(plant_type):
    combat_system.select_plant(plant_type)

func _on_wave_started(wave_number):
    wave_label.text = "Wave " + str(wave_number)

func _on_wave_completed(wave_number):
    wave_label.text = "Wave " + str(wave_number) + " Complete!"

func _on_game_over(victory):
    if victory:
        wave_label.text = "Victory!"
    else:
        wave_label.text = "Game Over!"

func get_sun_counter_position():
    return $SunCounter/SunIcon.global_position
