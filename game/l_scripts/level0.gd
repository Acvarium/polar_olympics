extends Node2D
var main_node
var global
export var v_slide_allow = false
export var tut_num = 0
export var beg = false
export var start_music = 3

func _ready():
	randomize()
	main_node = get_node("/root/main")
	global = get_node("/root/global")
	var cr_pos = get_node("cr").get_pos()
	if has_node("start_point"):
		main_node.start_pos = get_node("start_point").get_global_pos()
	main_node.target_pos = cr_pos
	main_node.remove_obj("target")
	main_node.remove_obj("walls")
	main_node.remove_obj("top_score")
	main_node.bonus10_on = false
	main_node.level_tutorial = tut_num
	if start_music != 2:
		start_music = randi() % 3 + 3
	main_node.start_music = start_music
	main_node.beg = beg
	global.max_throw = 3
	main_node.v_slide_allow = v_slide_allow 
	global.set_commands(1)
	main_node.geme_setup()
	main_node.camera_animation = 'fast_fire'
	if has_node("tut") and global.tutorial != 0:
		get_node("tut").play("tut")
	if has_node("cloud_ui_dot"):
		get_node("cloud_ui_dot").hide()