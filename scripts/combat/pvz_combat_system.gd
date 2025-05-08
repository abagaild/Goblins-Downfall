
extends Node
class_name PVZCombatSystem

# Grid configuration
@export var grid_width: int = 9
@export var grid_height: int = 5
@export var cell_size: Vector2 = Vector2(100, 100)

# Combat stats
@export var base_sun_generation: float = 25.0  # Sun generated per interval
@export var sun_generation_interval: float = 10.0  # Seconds between sun generation
@export var starting_sun: int = 50

# References
@export var stats_system_path: NodePath
@export var grid_container_path: NodePath

# Private variables
var stats_system = null
var grid_container = null
var grid_cells = []  # 2D array of cells
var current_sun: int = 0
var sun_timer: float = 0.0
var wave_timer: float = 0.0
var current_wave: int = 0
var is_wave_active: bool = false
var selected_plant: String = ""
var enemies_in_play = []
var plants_in_play = []

# Signals
signal sun_changed(amount)
signal wave_started(wave_number)
signal wave_completed(wave_number)
signal plant_placed(plant_type, grid_position)
signal enemy_spawned(enemy_type, lane)
signal game_over(victory)

func _ready():
	# Get references
	if stats_system_path:
		stats_system = get_node(stats_system_path)
	
	if grid_container_path:
		grid_container = get_node(grid_container_path)
	
	# Initialize grid
	initialize_grid()
	
	# Set starting sun
	current_sun = starting_sun
	emit_signal("sun_changed", current_sun)

func _process(delta):
	# Handle sun generation
	sun_timer += delta
	if sun_timer >= sun_generation_interval:
		generate_sun()
		sun_timer = 0.0
	
	# Handle wave spawning
	if is_wave_active:
		process_active_wave(delta)

func initialize_grid():
	grid_cells = []
	
	# Create grid cells
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			var cell = {
				"position": Vector2(x, y),
				"occupied": false,
				"plant": null,
				"enemies": []
			}
			row.append(cell)
		grid_cells.append(row)

func generate_sun():
	add_sun(base_sun_generation)

func add_sun(amount):
	current_sun += amount
	emit_signal("sun_changed", current_sun)

func use_sun(amount):
	if current_sun >= amount:
		current_sun -= amount
		emit_signal("sun_changed", current_sun)
		return true
	return false

func select_plant(plant_type):
	selected_plant = plant_type

func place_plant(grid_x, grid_y):
	# Check if position is valid
	if grid_x < 0 or grid_x >= grid_width or grid_y < 0 or grid_y >= grid_height:
		return false
	
	# Check if cell is already occupied
	if grid_cells[grid_y][grid_x].occupied:
		return false
	
	# Get plant data
	var plant_data = get_plant_data(selected_plant)
	if not plant_data:
		return false
	
	# Check if we have enough sun
	if not use_sun(plant_data.sun_cost):
		return false
	
	# Create plant instance
	var plant = load("res://scenes/combat/plants/" + selected_plant + ".tscn").instantiate()
	grid_container.add_child(plant)
	
	# Position plant - add grid offset
	var grid_offset = Vector2(100, 150)  # Same as in grid_interaction.gd
	plant.position = Vector2(grid_x * cell_size.x, grid_y * cell_size.y) + grid_offset + cell_size/2
	
	# Update grid cell
	grid_cells[grid_y][grid_x].occupied = true
	grid_cells[grid_y][grid_x].plant = plant
	
	# Add to plants in play
	plants_in_play.append(plant)
	
	# Connect signals
	plant.connect("plant_destroyed", Callable(self, "_on_plant_destroyed"))
	
	# Emit signal
	emit_signal("plant_placed", selected_plant, Vector2(grid_x, grid_y))
	
	return true

func start_wave(wave_number):
	current_wave = wave_number
	is_wave_active = true
	
	# Get wave data
	var wave_data = get_wave_data(wave_number)
	
	# Emit signal
	emit_signal("wave_started", wave_number)
	
	# Schedule enemy spawns
	for enemy_spawn in wave_data.enemies:
		var timer = get_tree().create_timer(enemy_spawn.delay)
		timer.timeout.connect(func(): spawn_enemy(enemy_spawn.type, enemy_spawn.lane))

func spawn_enemy(enemy_type, lane):
	# Check if lane is valid
	if lane < 0 or lane >= grid_height:
		return
	
	# Create enemy instance
	var enemy_path = "res://scenes/combat/enemies/" + enemy_type + ".tscn"
	print("Spawning enemy from path: " + enemy_path)
	
	var enemy = load(enemy_path).instantiate()
	grid_container.add_child(enemy)
	
	# Position enemy at the right edge of the grid in the specified lane
	var grid_offset = Vector2(100, 150)  # Same as in grid_interaction.gd
	enemy.position = Vector2(grid_width * cell_size.x, lane * cell_size.y) + grid_offset + Vector2(0, cell_size.y/2)
	
	# Set enemy lane
	enemy.lane = lane
	
	# Add to enemies in play
	enemies_in_play.append(enemy)
	
	# Connect signals
	enemy.connect("enemy_defeated", Callable(self, "_on_enemy_defeated"))
	enemy.connect("reached_end", Callable(self, "_on_enemy_reached_end"))
	
	# Emit signal
	emit_signal("enemy_spawned", enemy_type, lane)

func process_active_wave(delta):
	# Check if wave is complete
	if enemies_in_play.size() == 0 and is_wave_active:
		complete_wave()

func complete_wave():
	is_wave_active = false
	emit_signal("wave_completed", current_wave)
	
	# Check if this was the final wave
	if current_wave >= get_total_waves():
		emit_signal("game_over", true)  # Victory

func _on_plant_destroyed(plant):
	# Remove from plants in play
	plants_in_play.erase(plant)
	
	# Update grid cell
	for y in range(grid_height):
		for x in range(grid_width):
			if grid_cells[y][x].plant == plant:
				grid_cells[y][x].occupied = false
				grid_cells[y][x].plant = null
				break

func _on_enemy_defeated(enemy):
	# Remove from enemies in play
	enemies_in_play.erase(enemy)

func _on_enemy_reached_end(enemy):
	# Remove from enemies in play
	enemies_in_play.erase(enemy)
	
	# Game over - zombies reached the house
	emit_signal("game_over", false)  # Defeat

# Helper functions to get data
func get_plant_data(plant_type):
	# This would be replaced with actual data from a resource or database
	var plant_database = {
		"sunflower": {
			"sun_cost": 50,
			"health": 50,
			"sun_production": 25,
			"sun_interval": 24.0
		},
		"peashooter": {
			"sun_cost": 100,
			"health": 100,
			"damage": 20,
			"attack_interval": 1.5
		},
		"wallnut": {
			"sun_cost": 50,
			"health": 300
		}
	}
	
	if plant_database.has(plant_type):
		return plant_database[plant_type]
	return null

func get_wave_data(wave_number):
	# This would be replaced with actual data from a resource or database
	var waves = [
		{  # Wave 1
			"enemies": [
				{"type": "basic_goblin", "lane": 2, "delay": 5.0},
				{"type": "basic_goblin", "lane": 1, "delay": 10.0},
				{"type": "basic_goblin", "lane": 3, "delay": 15.0}
			]
		},
		{  # Wave 2
			"enemies": [
				{"type": "basic_goblin", "lane": 0, "delay": 3.0},
				{"type": "basic_goblin", "lane": 2, "delay": 5.0},
				{"type": "basic_goblin", "lane": 4, "delay": 7.0},
				{"type": "basic_goblin", "lane": 1, "delay": 12.0},
				{"type": "basic_goblin", "lane": 3, "delay": 15.0}
			]
		}
	]
	
	if wave_number - 1 < waves.size():
		return waves[wave_number - 1]
	return {"enemies": []}

func get_total_waves():
	# This would be replaced with actual data
	return 2
