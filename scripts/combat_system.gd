extends Node
class_name CombatSystem

# Combat stats
@export var base_damage: float = 10.0
@export var attack_speed: float = 1.0  # Attacks per second
@export var attack_range: float = 50.0
@export var resilience_cost: float = 5.0  # Mana cost per attack

# References
@export var stats_system_path: NodePath
@export var attack_cooldown_path: NodePath

# Private variables
var stats_system = null
var attack_cooldown = null
var can_attack: bool = true
var attack_timer: float = 0.0

# Signals
signal attack_performed(damage, position)
signal hit_landed(target, damage)

func _ready():
	# Get references
	if stats_system_path:
		stats_system = get_node(stats_system_path)
	
	if attack_cooldown_path:
		attack_cooldown = get_node(attack_cooldown_path)
		attack_cooldown.timeout.connect(_on_attack_cooldown_timeout)

func _process(delta):
	# Handle attack cooldown if not using a Timer node
	if not attack_cooldown and not can_attack:
		attack_timer += delta
		if attack_timer >= 1.0 / attack_speed:
			can_attack = true
			attack_timer = 0.0

func perform_attack():
	# Check if we can attack
	if not can_attack:
		return false
	
	# Check if we have enough resilience (mana)
	if stats_system and not stats_system.use_resilience(resilience_cost):
		return false
	
	# Start cooldown
	can_attack = false
	if attack_cooldown:
		attack_cooldown.wait_time = 1.0 / attack_speed
		attack_cooldown.start()
	else:
		attack_timer = 0.0
	
	# Emit attack signal
	emit_signal("attack_performed", base_damage, global_position)
	
	return true

func check_hit(target_position):
	# Check if target is within range
	var distance = global_position.distance_to(target_position)
	return distance <= attack_range

func apply_damage(target, damage_multiplier = 1.0):
	if target.has_method("take_damage"):
		var final_damage = base_damage * damage_multiplier
		target.take_damage(final_damage)
		emit_signal("hit_landed", target, final_damage)
		return true
	return false

func _on_attack_cooldown_timeout():
	can_attack = true
