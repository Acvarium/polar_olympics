extends Sprite
var pinches = [
0.8,
1.2,
1.5]

func _ready():
	pass

func star_reset():
	set_frame(1)

func star_on(n):
	get_node("anim").play("star_on")
	get_node("effect").get_sample_library().sample_set_pitch_scale("jeckkech__swim", pinches[n])