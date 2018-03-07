extends Control
export var layout = 0
var global
var throw_icons = 7
var main_node 

func _ready():
	global = get_node("/root/global")
	main_node = get_node("/root/main")
	get_node("rect").show()
	get_node("icon").show()
	get_node("point").show()
	get_node("under").show()
	get_node("icon").set_modulate(Color(1,1,1,0))
	set_layout(layout)
#	if main_node.team == layout:
#		get_node("layout").animation_set_next(

func set_trows(t):
	for i in range(throw_icons):
		if i < t:
			get_node("point/peng_ico" + str(i)).show()
		else:
			get_node("point/peng_ico" + str(i)).hide()

func set_team_avatar(a):
	get_node("icon").set_frame(a)

func set_team_name(n):
	get_node("under/label").set_text(n)

func set_team_score(s):
	get_node("under/score").set_text(str(s))

func set_team_color(c):
	get_node("under/label").add_color_override("font_color", c)

func play_anim(a):
	get_node("layout").play(a)

func set_level(l):
	get_node("under/score").set_text(tr("LEVEL") + "  " + str(l + 1))
	get_node("under/set").show()
	var set_num = int(l / 16) + 1
	get_node("under/set").set_text(tr("SET") + " " + str(set_num))
	

func set_layout(l):
	layout = l
	get_node("layout").play(str(l))

func _on_start_timer_timeout():
	if main_node.team == layout and !global.single:
		play_anim('in')