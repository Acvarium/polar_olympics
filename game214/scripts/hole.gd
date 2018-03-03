extends Sprite
var fall_pos_obj = load("res://objects/fall_pos.tscn")
var main_node
var swallowed = []
export var score = 0

func _ready():
	main_node = get_node("/root/main")
	set_score(score)
	main_node.bonus_counter(score)

func set_score(s):
	score = s
	if score == 0:
		get_node("arc").hide()
	else:
		get_node("arc").show()
		get_node("arc/Label").set_text(str(score))
		
	
func _on_Area2D_body_enter( body ):
	if  to_swallow(body):
		var fall_pos = fall_pos_obj.instance()
		add_child(fall_pos)
		fall_pos.set_global_pos(body.get_global_pos())
		fall_pos.set_rot(body.get_linear_velocity().angle() - PI/2)
		
		fall_pos.set_peng(body.get_path())
		swallowed.append(body.get_name())
		fall_pos.set_water(get_global_pos())
		if score > 0:
			if body.is_in_group("peng"):
				main_node.bonus(body.team, score, 'hole', get_global_pos())
			else:
				main_node.bonus(main_node.team, score, 'hole', get_global_pos())
		set_score(0)

func to_swallow(body):
	var not_swallowed = swallowed.find(body.get_name()) == -1
	var correct_group = (body.is_in_group("peng") or body.is_in_group("ball"))
	return not_swallowed and correct_group
