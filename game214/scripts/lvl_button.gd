extends Patch9Frame
export var level = 0
var global

func _ready():
	global = get_node("/root/global")
	get_node("Label").set_text("lvl" + str(level))

func _on_lvl_pressed():
	global.level_num = level
	global.select_next_level(0)
	global.single = true
	global.goto_scene("res://scenes/main.tscn")
