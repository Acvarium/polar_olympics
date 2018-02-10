extends RigidBody
var main

func _ready():
	main = get_node("/root/main")

func _on_penguin_sleeping_state_changed():
	print(sleeping)
	
