extends RigidBody2D
var score = 0
var main_node
var team = 0
var global
const team_color = [
	Color(1,1,1,1),
	Color(1,0.5,0,1),
]

func _ready():
	main_node = get_node("/root/main")
	global = get_node("/root/global")
	
func _physics_process(delta):
	var target_pos = main_node.target_pos
	var target_rad = main_node.target_radius
	var dist = global_position.distance_to(target_pos)
	score = (int(dist < target_rad) + int(dist < (target_rad * 0.75)) + int(dist < (target_rad * 0.5)) + int(dist < (target_rad * 0.25)) + int(dist < (target_rad * 0.078125))) * 2

func _on_penguin_sleeping_state_changed():
	set_physics_process(!sleeping)

func set_team(t):
	team = t

func set_color(c):
	$cloud_ui_dot.modulate = c