extends Area2D
export var score = 0
var main_node

func _ready():
	main_node = get_node("/root/main")
	if score > 0:
#		main_node.bonus_counter(score)
		if has_node("points"):
			get_node("points").show()
			get_node("points/Label").set_text(str(score))
	else:
		if has_node("points"):
			get_node("points").hide()

func set_score(s):
	score = s
	get_node("points/Label").set_text(str(score))
	if score == 0:
		get_node("points").hide()
	else:
		get_node("points").show()
		
