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
	for c in get_children():
		if c.is_in_group(get_name()):
			var dist = Vector2().distance_to(c.get_pos())
			print(dist)
			if dist > 200:
				main_node.move_from_platform(self.get_path(), c.get_path())


func _on_Area2D_body_enter( body ):
	if body.is_in_group("peng") and ! body.is_in_group(get_name()):
		main_node.move_to_platform(self.get_path(), body.get_path())
		body.add_to_group(get_name())
		
#func _on_platrofm_area_body_exit( body ):
#	return
#	if body.is_in_group(get_name()):
#		print(body.get_name())
#		main_node.move_from_platform(self.get_path(), body.get_path())

