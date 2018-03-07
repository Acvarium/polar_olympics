extends Position2D
var score = 10
var effect_type = ''

func _ready():
	get_node("Timer").start()

func set_timeout(t):
	get_node("Timer").set_wait_time(t)
	
func set_effect_type(t):
	effect_type = t
	
func set_bonus_score(s):
	score = s
	get_node("pos/Label").set_text(str(score))

func _on_anim_finished():
	queue_free()

func _on_Timer_timeout():
	if effect_type == 'hole':
		get_node("sounds/hole").play()
	elif effect_type == 'fish':
		get_node("sounds/fish").play()
	elif effect_type == 'bonus10':
		get_node("sounds/bonus10").play()
	get_node("anim").play("effect")
	
		
