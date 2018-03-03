extends RigidBody2D
export var score = 10
var main_node

func _ready():
	main_node = get_node("/root/main")
	set_score(score)
	main_node.bonus_counter(score)

func set_score(s):
	score = s
	get_node("score_label/Label").set_text(str(score))
	if score == 0:
		get_node("score_label/Label").hide()
	else:
		get_node("score_label/Label").show()
		
		