extends EnemyBase
class_name PsychosisBoss

# Boss-specific properties
var hallucination_active = false
var reality_distortion = 0.0

func _ready():
    super._ready()
    
    # Set up boss stats
    enemy_name = "Psychosis"  # Changed from name to enemy_name
    max_health = 300.0
    current_health = max_health
    attack_power = 15.0
    defense = 8.0
    is_boss = true
    
    # Boss-specific attacks
    attacks = ["hallucination_wave", "reality_warp", "paranoid_spiral"]
    
    emit_signal("health_changed", current_health, max_health)

func choose_attack():
    # Boss has phase-based attacks
    if current_health < max_health * 0.3:
        # Desperate phase
        current_attack = "reality_collapse"
    elif current_health < max_health * 0.6:
        # Choose from mid-battle attacks
        var options = ["hallucination_wave", "reality_warp", "paranoid_spiral"]
        current_attack = options[randi() % options.size()]
    else:
        # Early battle attacks
        var options = ["hallucination_wave", "paranoid_spiral"]
        current_attack = options[randi() % options.size()]
    
    emit_signal("attack_chosen", current_attack)
    
    if animation_player:
        animation_player.play("attack_" + current_attack)
    
    return current_attack

func get_bullet_pattern(attack_name):
    match attack_name:
        "hallucination_wave":
            return "psychosis"
        "reality_warp":
            hallucination_active = true
            return "hallucination"
        "paranoid_spiral":
            return "spiral"
        "reality_collapse":
            reality_distortion = 1.0
            return "psychosis"
    return "psychosis"

# Override take_damage to implement boss mechanics
func take_damage(amount):
    var actual_damage = amount
    
    # Hallucinations reduce damage
    if hallucination_active:
        actual_damage *= 0.5
        
    # Reality distortion can cause damage to be reflected
    if reality_distortion > 0 and randf() < reality_distortion:
        return 0
    
    return super.take_damage(actual_damage)