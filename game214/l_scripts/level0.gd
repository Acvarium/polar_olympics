extends Node2D
var main_node
var global

func _ready():
	main_node = get_node("/root/main")
	global = get_node("/root/global")
#	global.set_commands(4)
	var cr_pos = get_node("cr").get_pos()
	main_node.target_pos = cr_pos
	main_node.remove_obj("target")
	main_node.remove_obj("walls")
	main_node.remove_obj("top_score")
	main_node.bonus10_on = false
	global.max_throw = 3
	global.select_next_level(1)
	global.set_commands(1)
	main_node.geme_setup()
	main_node.camera_animation = 'fast_fire'
	
	
	