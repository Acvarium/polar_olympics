extends RigidBody2D
var score = 0
var main_node
var team = 0
var global
var default_damp = 0.7
var turn = 0
var bonus_ten = false

const team_color = [
	Color(1,1,1,1),
	Color(1,0.5,0,1),
]

func _ready():
	main_node = get_node("/root/main")
	global = get_node("/root/global")
	

func reset_damp():
	linear_damp = default_damp
	angular_damp = default_damp

func set_damp(d):
	linear_damp = d
	angular_damp = d
	
func _physics_process(delta):
	var target_pos = main_node.target_pos
	var target_rad = main_node.target_radius
	var dist = global_position.distance_to(target_pos)
	score = (int(dist < target_rad) + int(dist < (target_rad * 0.75)) + int(dist < (target_rad * 0.5)) + int(dist < (target_rad * 0.25)) + int(dist < (target_rad * 0.078125))) * 2
	
func _on_penguin_sleeping_state_changed():
	set_physics_process(!sleeping)
	if sleeping:
		$anim.stop(true)
		$anim_timer.stop()
	else:
		$anim.play("move")
		
	if sleeping and score == 10 and ! bonus_ten:
		bonus_ten = true
		main_node.add_bonus_fish()
	
func set_team(t):
	team = t

func set_color(c):
	$cloud_ui_dot.modulate = c

func _on_anim_timer_timeout():
	$anim.playback_speed *= 0.9
	if $anim.playback_speed < 0.5:
		$anim.playback_speed = 0.5
