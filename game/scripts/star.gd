extends Sprite
export var rate_star = false
var pinches = [
0.8,
1.2,
1.5]

func _ready():
	if rate_star:
		set_frame(0)
#		get_node("particles").set_emitting(true)

func star_reset():
	set_frame(1)

func set_star(s):
	rate_star = s
	if rate_star:
		set_frame(0)
	else:
		set_frame(1)
		

func star_on(n):
	get_node("anim").play("star_on")
	get_node("effect").get_sample_library().sample_set_pitch_scale("jeckkech__swim", pinches[n])