extends EnemyBase
class_name OCDBoss

# Boss-specific properties
var pattern_strength = 0
var ritual_counter = 0
var protective_patterns = []

func _ready():
    super._ready()
    
    # Set up boss stats
    enemy_name = "OCD"  # Changed from name to enemy_name
    max_health = 280.0
    current_health = max_health
    attack_power = 10.0
    defense = 12.0
    is_boss = true
    
    # Boss-specific attacks
    attacks = ["intrusive_thoughts", "compulsive_ritual", "symmetry_demand"]
    
    # Initialize protective patterns
    protective_patterns = [false, false, false, false]
    
    emit_signal("health_changed", current_health, max_health)

func choose_attack():
    # OCD follows strict patterns
    ritual_counter += 1
    
    if ritual_counter % 4 == 0:
        current_attack = "perfect_symmetry"
        pattern_strength = 3
    elif ritual_counter % 3 == 0:
        current_attack = "compulsive_ritual"
        # Activate a protective pattern
        var pattern_index = randi() % protective_patterns.size()
        protective_patterns[pattern_index] = true
    else:
        var options = ["intrusive_thoughts", "symmetry_demand"]
        current_attack = options[randi() % options.size()]
    
    emit_signal("attack_chosen", current_attack)
    
    if animation_player:
        animation_player.play("attack_" + current_attack)
    
    return current_attack

func get_bullet_pattern(attack_name):
    match attack_name:
        "intrusive_thoughts":
            return "basic"
        "compulsive_ritual":
            return "pattern"
        "symmetry_demand":
            return "ocd"
        "perfect_symmetry":
            return "pattern"
    return "ocd"

# Override take_damage to implement boss mechanics
func take_damage(amount):
    var actual_damage = amount
    
    # Check if damage is blocked by a protective pattern
    var pattern_active = false
    for i in range(protective_patterns.size()):
        if protective_patterns[i]:
            pattern_active = true
            protective_patterns[i] = false
            break
    
    if pattern_active:
        actual_damage *= 0.2
    
    # Breaking patterns causes more damage
    if pattern_strength > 0:
        actual_damage *= 0.5
        pattern_strength -= 1
    
    return super.take_damage(actual_damage)