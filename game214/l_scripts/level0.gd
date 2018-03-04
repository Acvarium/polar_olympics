extends Node2D
var main_node
var global

func _ready():
	main_node = get_node("/root/main")
	global = get_node("/root/global")
	var cr_pos = get_node("cr").get_pos()
	main_node.target_pos = cr_pos
	main_node.remove_obj("target")
	main_node.remove_obj("walls")
	main_node.remove_obj("top_score")
	main_node.bonus10_on = false
	if global.level_num != 0:
		main_node.level_tutorial = 0
	global.max_throw = 3
	if global.level_num == 4:
		main_node.v_slide_allow = true
	global.set_commands(1)
	main_node.geme_setup()
	main_node.camera_animation = 'fast_fire'