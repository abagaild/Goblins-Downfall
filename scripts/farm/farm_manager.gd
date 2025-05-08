extends Node2D
class_name FarmManager

# Farm properties
@export var grid_width: int = 3
@export var grid_height: int = 3
@export var cell_size: Vector2 = Vector2(100, 100)
@export var grid_offset: Vector2 = Vector2(100, 150)

# Resources
var hope_seeds: int = 3
var upgrade_points: int = 0
var sun_resource: int = 100

# Grid state
var farm_plots = []

# References
@onready var plot_scene = preload("res://scenes/farm/farm_plot.tscn")

# Signals
signal seed_planted(plot_x, plot_y, seed_type)
signal plot_harvested(plot_x, plot_y, yield_amount)
signal resources_changed(hope_seeds, upgrade_points, sun)
signal day_completed

# Upgrade variables
var yield_multiplier = 1.0
var growth_time_multiplier = 1.0
var unlocked_plants = {
	"hope_seed": true,  # Default plant
	"grounding": false,
	"mindfulness": false,
	"compassion": false
}

func _ready():
	initialize_farm_grid()
	emit_signal("resources_changed", hope_seeds, upgrade_points, sun_resource)
	
	# Start day/night cycle - find it in the parent scene
	var day_night_cycle = get_parent().get_node_or_null("DayNightCycle")
	if day_night_cycle:
		day_night_cycle.start()
	else:
		print("Warning: DayNightCycle node not found")

func initialize_farm_grid():
	# Create 2D array of farm plots
	farm_plots = []
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			var plot = plot_scene.instantiate()
			add_child(plot)
			
			# Position plot
			plot.position = Vector2(x * cell_size.x, y * cell_size.y) + grid_offset
			
			# Connect signals
			plot.connect("plot_clicked", Callable(self, "_on_plot_clicked"))
			
			# Store plot data
			row.append({
				"plot": plot,
				"planted": false,
				"growth_time": 0,
				"seed_type": "",
				"harvestable": false
			})
		farm_plots.append(row)

func _on_plot_clicked(plot):
	# Find plot coordinates
	for y in range(grid_height):
		for x in range(grid_width):
			if farm_plots[y][x].plot == plot:
				handle_plot_interaction(x, y)
				return

func handle_plot_interaction(x, y):
	var plot_data = farm_plots[y][x]
	
	# If plot is harvestable, harvest it
	if plot_data.harvestable:
		harvest_plot(x, y)
	# If plot is empty, plant a seed
	elif not plot_data.planted and hope_seeds > 0:
		plant_seed(x, y, "hope_seed")

func plant_seed(x, y, seed_type):
	if hope_seeds <= 0:
		return
		
	var plot_data = farm_plots[y][x]
	plot_data.planted = true
	plot_data.seed_type = seed_type
	plot_data.growth_time = 0
	plot_data.harvestable = false
	
	# Update plot visuals
	plot_data.plot.set_state("growing")
	
	# Use a seed
	hope_seeds -= 1
	emit_signal("resources_changed", hope_seeds, upgrade_points, sun_resource)
	emit_signal("seed_planted", x, y, seed_type)
	
	# Start growth timer with multiplier applied
	var base_growth_time = 10.0  # 10 seconds for testing
	var modified_growth_time = base_growth_time * growth_time_multiplier
	var growth_timer = get_tree().create_timer(modified_growth_time)
	growth_timer.timeout.connect(func(): _on_growth_complete(x, y))

func _on_growth_complete(x, y):
	var plot_data = farm_plots[y][x]
	plot_data.harvestable = true
	
	# Update plot visuals
	plot_data.plot.set_state("harvestable")

func harvest_plot(x, y):
	var plot_data = farm_plots[y][x]
	
	# Calculate yield with multiplier
	var base_yield = randi_range(5, 15)  # Random yield between 5-15
	var modified_yield = floor(base_yield * yield_multiplier)
	var sun_yield = randi_range(10, 30)
	
	# Add resources
	upgrade_points += modified_yield
	sun_resource += sun_yield
	
	# Add a chance to get a seed back
	if randf() < 0.3:  # 30% chance
		hope_seeds += 1
	
	# Reset plot
	plot_data.planted = false
	plot_data.harvestable = false
	plot_data.seed_type = ""
	
	# Update plot visuals
	plot_data.plot.set_state("empty")
	
	# Update UI
	emit_signal("resources_changed", hope_seeds, upgrade_points, sun_resource)
	emit_signal("plot_harvested", x, y, modified_yield)

func add_hope_seed(amount: int = 1):
	hope_seeds += amount
	emit_signal("resources_changed", hope_seeds, upgrade_points, sun_resource)

# Add a new plot to the farm
func add_farm_plot():
	# Determine where to add the new plot
	if grid_width < 5:  # Expand horizontally first
		grid_width += 1
	else:  # Then expand vertically
		grid_height += 1
	
	# Reinitialize the farm grid with the new dimensions
	# First, remove all existing plots
	for row in farm_plots:
		for plot_data in row:
			plot_data.plot.queue_free()
	
	# Then recreate the grid
	initialize_farm_grid()

# Increase yield multiplier
func increase_yield(amount):
	yield_multiplier += amount

# Decrease growth time
func decrease_growth_time(percent):
	growth_time_multiplier -= percent
	# Ensure it doesn't go below 0.2 (80% reduction max)
	growth_time_multiplier = max(0.2, growth_time_multiplier)

# Unlock a new plant type
func unlock_plant(plant_type):
	unlocked_plants[plant_type] = true

func _on_day_night_cycle_timeout():
	emit_signal("day_completed")

func _on_to_defense_button_pressed():
	# Stop the timer if it's running
	$DayNightCycle.stop()
	
	# Emit day completed signal to trigger defense phase
	emit_signal("day_completed")
