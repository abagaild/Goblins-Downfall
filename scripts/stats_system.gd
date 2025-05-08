extends Node
class_name StatsSystem

# Base stats
@export var max_fortitude: float = 100.0  # Health
@export var max_resilience: float = 100.0  # Mana
@export var fortitude_regen: float = 0.0  # Health regeneration per second
@export var resilience_regen: float = 5.0  # Mana regeneration per second

# Current stats
var current_fortitude: float
var current_resilience: float
var shield_amount: float = 0.0
var defense_buff: float = 1.0
var defense_buff_turns: int = 0
var attack_buff: float = 1.0
var attack_buff_turns: int = 0

# Signals
signal fortitude_changed(current, maximum)
signal resilience_changed(current, maximum)
signal shield_changed(amount)
signal buff_applied(type, value, turns)
signal died

func _ready():
	# Initialize stats
	current_fortitude = max_fortitude
	current_resilience = max_resilience
	
	# Emit initial signals
	emit_signal("fortitude_changed", current_fortitude, max_fortitude)
	emit_signal("resilience_changed", current_resilience, max_resilience)

func _process(delta):
	# Handle regeneration
	if fortitude_regen > 0:
		heal(fortitude_regen * delta)
	
	if resilience_regen > 0:
		restore_resilience(resilience_regen * delta)

func take_damage(amount):
	# Apply defense buff if active
	if defense_buff_turns > 0:
		amount *= defense_buff
		defense_buff_turns -= 1
	
	# Shield absorbs damage first
	if shield_amount > 0:
		if shield_amount >= amount:
			shield_amount -= amount
			amount = 0
		else:
			amount -= shield_amount
			shield_amount = 0
		
		emit_signal("shield_changed", shield_amount)
	
	# Apply remaining damage to fortitude
	current_fortitude -= amount
	current_fortitude = max(0, current_fortitude)
	
	emit_signal("fortitude_changed", current_fortitude, max_fortitude)
	
	if current_fortitude <= 0:
		emit_signal("died")

func heal(amount):
	current_fortitude += amount
	current_fortitude = min(current_fortitude, max_fortitude)
	
	emit_signal("fortitude_changed", current_fortitude, max_fortitude)

func use_resilience(amount):
	if current_resilience < amount:
		return false
	
	current_resilience -= amount
	emit_signal("resilience_changed", current_resilience, max_resilience)
	
	return true

func restore_resilience(amount):
	current_resilience += amount
	current_resilience = min(current_resilience, max_resilience)
	
	emit_signal("resilience_changed", current_resilience, max_resilience)

func add_shield(amount):
	shield_amount += amount
	emit_signal("shield_changed", shield_amount)

func add_defense_buff(multiplier, turns):
	defense_buff = multiplier
	defense_buff_turns = turns
	emit_signal("buff_applied", "defense", multiplier, turns)

func add_attack_buff(multiplier, turns):
	attack_buff = multiplier
	attack_buff_turns = turns
	emit_signal("buff_applied", "attack", multiplier, turns)

func get_attack_multiplier():
	if attack_buff_turns > 0:
		attack_buff_turns -= 1
		return attack_buff
	return 1.0

func set_fortitude(amount):
	current_fortitude = min(amount, max_fortitude)
	emit_signal("fortitude_changed", current_fortitude, max_fortitude)

func set_resilience(amount):
	current_resilience = min(amount, max_resilience)
	emit_signal("resilience_changed", current_resilience, max_resilience)
