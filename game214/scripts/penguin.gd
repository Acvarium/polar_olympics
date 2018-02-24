extends RigidBody2D
var score = 0
var main_node
var team = 0
var global
var default_damp = 0.7
var turn = 0
var bonus_ten = false
var old_score = 0
var target_pos = Vector2()
var target_rad = 0
var id = 0
var is_falling = false

func _ready():
	global = get_node("/root/global")
	main_node = get_node("/root/main")
	target_pos = main_node.target_pos
	target_rad = main_node.target_radius
	set_fixed_process(true)
	if !is_falling:
		get_node("yahoo").play("yahoo")
#	else:
#		set_mode(3)
#		get_node("anim").play("fall")

func set_id(i):
	id = i
	
func reset_damp():
	set_linear_damp(default_damp)
	set_angular_damp(default_damp)

func set_damp(d):
	set_linear_damp(d)
	set_angular_damp(d)
	
func _fixed_process(delta):
	var global_position = get_global_pos()
	var dist = global_position.distance_to(target_pos)
	score = (int(dist < target_rad) + int(dist < (target_rad * 0.75)) + int(dist < (target_rad * 0.5)) + int(dist < (target_rad * 0.25)) + int(dist < (target_rad * 0.078125))) * 2
	if get_node("flag").is_visible():
		get_node("flag").set_rot(-get_rot())
	if old_score != score:
		get_node("flag/sprite/Label").set_text(str(score))
		main_node.update_peng_score(id, score)
		
		if score > 0 and !get_node("flag").is_visible():
			get_node("flag").show()
		elif score <= 0 and get_node("flag").is_visible():
			get_node("flag").hide()
	old_score = score
	
func _on_penguin_sleeping_state_changed():
	set_fixed_process(!is_sleeping())
	
	if is_sleeping():
		get_node("anim").stop(true)
		get_node("anim_timer").stop()
	else:
		get_node("anim").play("move")
	if is_sleeping() and score == 10 and ! bonus_ten:
		bonus_ten = true
		main_node.add_bonus_fish()
	
func set_team(t):
	team = t

func set_color(c):
	get_node("cloud_ui_dot").set_modulate(c)
	get_node("flag/sprite").set_modulate(c)

func _on_anim_timer_timeout():
	var playback_speed = get_node("anim").get_speed()
	playback_speed *= 0.9
	get_node("anim").set_speed(playback_speed)
	if playback_speed < 0.5:
		get_node("anim").set_speed(0.5)