extends Sprite
var fall_pos_obj = load("res://objects/fall_pos.tscn")
var main_node
var swallowed = []

func _ready():
	main_node = get_node("/root/main")

func _on_Area2D_body_enter( body ):
	if  to_swallow(body):
		var fall_pos = fall_pos_obj.instance()
		add_child(fall_pos)
		fall_pos.set_global_pos(body.get_global_pos())
		fall_pos.set_rot(body.get_rot())
		
		fall_pos.set_peng(body.get_path())
		swallowed.append(body.get_name())
		fall_pos.set_water(get_global_pos())
	var ss = ''
	for i in range(swallowed.size()):
		ss += swallowed[i]
		ss += '\n'
	get_node("Label").set_text(ss)

func to_swallow(body):
	var not_swallowed = swallowed.find(body.get_name()) == -1
	print(not_swallowed)
	var correct_group = (body.is_in_group("peng") or body.is_in_group("ball"))

	return not_swallowed 
