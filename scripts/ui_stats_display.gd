extends Control

# References to UI elements
@onready var fortitude_bar = $FortitudeBar
@onready var resilience_bar = $ResilienceBar
@onready var fortitude_label = $FortitudeLabel
@onready var resilience_label = $ResilienceLabel

# Path to the player or entity with stats
@export var stats_owner_path: NodePath

# Reference to the stats owner
var stats_owner = null

func _ready():
	# Get reference to the stats owner
	if stats_owner_path:
		stats_owner = get_node(stats_owner_path)
		
		# Connect signals
		if stats_owner.has_signal("fortitude_changed"):
			stats_owner.connect("fortitude_changed", _on_fortitude_changed)
		
		if stats_owner.has_signal("resilience_changed"):
			stats_owner.connect("resilience_changed", _on_resilience_changed)
		
		# Initialize UI
		_update_ui()

func _update_ui():
	if stats_owner:
		# Update fortitude (health) display
		if fortitude_bar:
			fortitude_bar.max_value = stats_owner.max_fortitude
			fortitude_bar.value = stats_owner.current_fortitude
		
		if fortitude_label:
			fortitude_label.text = str(int(stats_owner.current_fortitude)) + "/" + str(int(stats_owner.max_fortitude))
		
		# Update resilience (mana) display
		if resilience_bar:
			resilience_bar.max_value = stats_owner.max_resilience
			resilience_bar.value = stats_owner.current_resilience
		
		if resilience_label:
			resilience_label.text = str(int(stats_owner.current_resilience)) + "/" + str(int(stats_owner.max_resilience))

func _on_fortitude_changed(current, maximum):
	if fortitude_bar:
		fortitude_bar.max_value = maximum
		fortitude_bar.value = current
	
	if fortitude_label:
		fortitude_label.text = str(int(current)) + "/" + str(int(maximum))

func _on_resilience_changed(current, maximum):
	if resilience_bar:
		resilience_bar.max_value = maximum
		resilience_bar.value = current
	
	if resilience_label:
		resilience_label.text = str(int(current)) + "/" + str(int(maximum))
