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
var iglu
export var tut = false
var rot_to_velocity = false
#var canvas
var in_water = false
var islands = []

func _ready():
	global = get_node("/root/global")
	main_node = get_node("/root/main")
#	canvas = main_node.get_node("draw")
	target_pos = main_node.target_pos
	target_rad = main_node.target_radius
	set_fixed_process(true)
	if global.single:
		get_node("cloud_ui_dot").hide()
	
	
#	
func set_id(i):
	id = i

func set_vel(vel):
	set_linear_velocity(vel)
	set_rot(vel.normalized().angle() - PI/2)
	
func reset_damp():
	set_linear_damp(default_damp)
	set_angular_damp(default_damp)

func set_damp(d):
	set_linear_damp(d)
	set_angular_damp(d)
	
func eat():
	get_node("anim").play("eat")

func _fixed_process(delta):
	if in_water and islands.size() == 0:
		if get_node("in_water").get_time_left() == 0:
			print(get_node("in_water").get_time_left() )
			get_node("in_water").start()
	else:
		get_node("in_water").stop()
		
	var angle = get_rot()
	var direction = Vector2(cos(get_rot()), -sin(get_rot())).normalized()
	var dd = get_linear_velocity().normalized()
	var doo = direction.dot(dd)
	
	if get_linear_velocity().length() > 10 and rot_to_velocity:
	
		if doo >= 0:
			set_rot(get_linear_velocity().angle()-PI/2)
		else:
			set_rot(get_linear_velocity().angle()+PI/2)
#			
		set_angular_velocity(0)
#		set_angular_velocity((get_rot() - (get_linear_velocity().angle()-PI/2))*5.0)
	var global_position = get_global_pos()
	var dist = global_position.distance_to(target_pos)
	score = (int(dist < target_rad) + int(dist < (target_rad * 0.75)) + int(dist < (target_rad * 0.5)) + int(dist < (target_rad * 0.25)) + int(dist < (target_rad * 0.078125))) * 2
	if get_node("flag").is_visible():
		get_node("flag").set_rot(-get_rot())
	if old_score != score:
		get_node("flag/sprite/Label").set_text(str(score))
		main_node.update_peng_score(id, score)
#		get_linear_velocity().
		if score > 0 and !get_node("flag").is_visible():
			get_node("flag").show()
		elif score <= 0 and get_node("flag").is_visible():
			get_node("flag").hide()
	old_score = score
	if global.single:
		var sp = get_linear_velocity().length()
		if sp < 30:
			set_linear_damp(10)
			set_angular_damp(15)
		else:
			set_linear_damp(.7)
			set_angular_damp(0.7)
		
	
func _on_penguin_sleeping_state_changed():
	set_fixed_process(!is_sleeping())
	
	if is_sleeping():
		get_node("anim").stop(true)
		get_node("anim_timer").stop()
		if iglu:
			if iglu.get_ref():
				if iglu.get_ref().score > 0:
					var s = iglu.get_ref().score
					main_node.bonus(team, s, 'iglu', get_global_pos())
					iglu.get_ref().set_score(0)
		
	else:
		set_linear_damp(.7)
		set_angular_damp(0.7)
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

func _on_anim_finished():
	var current_anim = get_node("anim").get_current_animation()
	if current_anim == 'eat':
		get_node("anim").play("move")

func _on_Area2D_area_enter( area ):
	if area.is_in_group("iglu"):
		iglu = weakref(area.get_parent())
	elif area.is_in_group("bonus_area"):
		iglu = weakref(area)
func _on_Area2D_area_exit( area ):
	if area.is_in_group("iglu") and iglu != null:
		if iglu.get_ref() == area.get_parent():
			iglu = null
	elif area.is_in_group("bonus_area") and iglu != null:
		if iglu.get_ref() == area:
			iglu = null
			
func _on_water_detector_area_enter( area ):
	if area.is_in_group("water"):
		in_water = true
	elif area.is_in_group("island"):
		if islands.find(area.get_path()) == -1:
			islands.append(area.get_path())
	elif area.is_in_group("end"):
		queue_free()
		
func _on_water_detector_area_exit( area ):
	if area.is_in_group("water"):
		in_water = false
	elif area.is_in_group("island"):
		if islands.find(area.get_path()) != -1:
			islands.remove(islands.find(area.get_path()))

func _on_in_water_timeout():
#	if in_water:
	main_node.add_splash(get_global_pos())
	queue_free()

func norm_rot_on():
	get_node("to_norm_rot").start()
	
func norm_rot_off():
	get_node("to_norm_rot").stop()
	rot_to_velocity = true
	
	
func _on_to_norm_rot_timeout():
	rot_to_velocity = false
