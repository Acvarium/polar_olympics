extends Position2D
var peng = ''
var main_node

func _ready():
	main_node = get_node("/root/main")

func set_peng(p):
	peng = p

func _on_Timer_timeout():
	if peng != '':
		main_node.fall(peng,get_node("n").get_path())
				
func set_water(pos):
	get_node("water_test").set_global_pos(pos)
	
func _on_anim_finished():
	queue_free()