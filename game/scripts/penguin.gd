extends RigidBody
var main
var tak = 0

func _ready():
	randomize()
	main = get_node("/root/main")
	$yahoo.play()

func _on_penguin_sleeping_state_changed():
	if sleeping:
		$peng.anim_stop()
	else:
		$peng.anim_play()
		

