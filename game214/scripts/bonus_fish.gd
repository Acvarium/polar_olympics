extends Area2D
var main_node

func _ready():
	main_node = get_node("/root/main")
	
func _on_bonus_fish_body_enter( body ):
	if body.is_in_group("peng"):
		body.eat()
		main_node.bonus(body.team, 1, 'fish', get_global_pos())
		queue_free()

