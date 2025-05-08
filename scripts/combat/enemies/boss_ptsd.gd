extends EnemyBase
class_name PTSDBoss

# Boss-specific properties
var trigger_level = 0
var flashback_active = false
var hypervigilance = false

func _ready():
    super._ready()
    
    # Set up boss stats
    enemy_name = "PTSD"  # Changed from name to enemy_name
    max_health = 320.0
    current_health = max_health
    attack_power = 18.0
    defense = 10.0
    is_boss = true
    
    # Boss-specific attacks
    attacks = ["startle_response", "emotional_numbness", "hypervigilance"]
    
    emit_signal("health_changed", current_health, max_health)

func choose_attack():
    # PTSD has trigger-based attacks
    if trigger_level >= 3:
        current_attack = "flashback"
        flashback_active = true
        trigger_level = 0
    elif hypervigilance:
        current_attack = "startle_response"
        hypervigilance = false
    else:
        var options = ["startle_response", "emotional_numbness", "hypervigilance"]
        current_attack = options[randi() % options.size()]
        
        if current_attack == "hypervigilance":
            hypervigilance = true
    
    emit_signal("attack_chosen", current_attack)
    
    if animation_player:
        animation_player.play("attack_" + current_attack)
    
    return current_attack

func get_bullet_pattern(attack_name):
    match attack_name:
        "startle_response":
            trigger_level += 1
            return "rapid"
        "emotional_numbness":
            return "basic"
        "hypervigilance":
            return "ptsd"
        "flashback":
            return "flashback"
    return "ptsd"

# Override take_damage to implement boss mechanics
func take_damage(amount):
    var actual_damage = amount
    
    # Flashbacks make the boss temporarily invulnerable
    if flashback_active:
        flashback_active = false
        return 0
    
    # Taking damage increases trigger level
    trigger_level += 1
    
    # Hypervigilance reduces damage
    if hypervigilance:
        actual_damage *= 0.7
    
    return super.take_damage(actual_damage)