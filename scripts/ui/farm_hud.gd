extends CanvasLayer
class_name FarmHUD

# References
@onready var seeds_label = $MarginContainer/HBoxContainer/SeedsContainer/SeedsLabel
@onready var points_label = $MarginContainer/HBoxContainer/PointsContainer/PointsLabel
@onready var sun_label = $MarginContainer/HBoxContainer/SunContainer/SunLabel

# Signals
signal upgrade_button_pressed

func _ready():
	# Connect to farm manager signals
	var farm_manager = get_tree().get_nodes_in_group("farm_manager")[0]
	if farm_manager:
		farm_manager.connect("resources_changed", Callable(self, "update_resources"))

func update_resources(hope_seeds, upgrade_points, sun):
	seeds_label.text = str(hope_seeds)
	points_label.text = str(upgrade_points)
	sun_label.text = str(sun)

func _on_upgrade_button_pressed():
	emit_signal("upgrade_button_pressed")
