extends Node2D
var main_node
export var rot_speed = 1.0

func _ready():
	main_node = get_node("/root/main")
	set_fixed_process(true)

func _fixed_process(delta):
	var rot = get_rot()
	rot += rot_speed * delta
	set_rot(rot)
	
