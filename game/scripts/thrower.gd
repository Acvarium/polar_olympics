extends Spatial
var main_node
var wb_mat = load("res://models/wb_mat.tres")
var bb_mat = load("res://models/bb_mat.tres")

func _ready():
	main_node = get_node("/root/main")

func set_team(t):
	if t == 0:
		get_node("Armature/Skeleton/bear.001").set_material_override(wb_mat)
	else:
		get_node("Armature/Skeleton/bear.001").set_material_override(bb_mat)
		

func throw():
	$AnimationPlayer.play("throw")

func stay():
	$AnimationPlayer.play("stay")
	
func _on_AnimationPlayer_animation_finished( anim_name ):
	if anim_name == "throw":
		main_node.spawn_penguin()
	if anim_name == "stay":
		get_parent().hide()
