extends Node2D
var screen_size = Vector2()
var screen_scale = Vector2()
var penguin_obj = load("res://objects/penguin.tscn")
var flag_obj = load("res://objects/flag.tscn")
var global
var state = 0
var throws = []
var score = []
var bonus_score = []
var max_throw = 1
var team = 0
var no_control = false
var pointer
var power_speed = 150
var max_power = 90
var min_power = 5
var power = 75
var rDir = 1
var dMinMax = 1
var pDirection = 0
var pSpeed = 2
var go = false
var target_pos = Vector2()
var target_radius = 384.0
var game_stop = false
var to_restart = false

func _ready():
	global = get_node("/root/global")
	global.current_scene = get_tree().get_current_scene()
	pointer = get_node("ui/pointer")
	set_process_input(true)
	resizer()
	var total_score_str = ''
	for i in range(global.score.size()):
		total_score_str += str(global.score[i])
		if i < (global.score.size() - 1):
			total_score_str += ":"
	get_node("canvas/data_ui/total_score").set_text(total_score_str)
	
	target_pos = get_node("game_field/target").get_global_pos()
	get_tree().get_root().connect("size_changed", self, "resizer")
	for i in range(4):
		get_node("canvas/data_ui/player" + str(i)).hide()
	for i in range(global.score.size()):
		throws.append(max_throw)
		score.append(0)
		bonus_score.append(0)
		get_node("canvas/data_ui/player" + str(i)).show()
		get_node("canvas/data_ui/player" + str(i)).set_team_color(global.team_color[i])
		get_node("canvas/data_ui/player" + str(i)).set_trows(max_throw)
		get_node("canvas/data_ui/player" + str(i)).set_team_avatar(global.selected_players[i])
		get_node("canvas/data_ui/player" + str(i)).set_team_name(global.player_name[i])
		if i == 0:
			get_node("canvas/data_ui/player" + str(i)).set_team_color(Color(0.7,0.7,0.7,1))
			
	set_process(true)
	get_node("canvas/data_ui/player0").play_anim("in")
	
#------------------------------
func _input(event):
	if event.is_action_pressed("quit"):
		get_tree().quit()

	if event.is_action_pressed("fire"):
		fire_pressed()

#========================================================================
func _process(delta):
	for i in range(score.size()):
		score[i] = 0
	for f in get_node("ui/flags").get_children():
		var peng = f.penguin
		f.set_pos(peng.get_pos())
		if peng.score > 0:
			f.get_node("sprite/label").set_text(str(peng.score))
		score[peng.team] += peng.score
		if peng.score > 0 and !f.is_visible():
			f.show()
		elif peng.score <= 0 and f.is_visible():
			f.hide()
	
	for i in range(score.size()):
		score[i] += bonus_score[i]
		get_node("canvas/data_ui/player" + str(i)).set_team_score(score[i])

	if go:
		var all_sleep = true
		for p in get_node("game_field/penguins").get_children():
			if !p.is_sleeping():
				all_sleep = false
		if all_sleep and !game_stop:
			game_stop = true
			var winers = get_winers()
			var total_score_str = ''
			for i in range(winers.size()):
				global.score[i] += winers[i]
				total_score_str += str(global.score[i])
				if i < (global.score.size() - 1):
					total_score_str += ":"
			get_node("canvas/data_ui/total_score_tab/score").set_text(total_score_str)
			get_node("canvas/data_ui/total_score").set_text(total_score_str)
			get_node("canvas/score_anim").play("show_score")
			to_restart = true

	if state == 0:
		power += power_speed * rDir * delta
		if power > max_power:
			rDir = -1
		if power < min_power:
			rDir = 1
		get_node("ui/power").set_value(power)
				
	elif state == 1:
		pDirection += pSpeed * rDir * delta
		if rDir == 1:
			if pDirection > dMinMax:
				rDir = -1
		else:
			if pDirection < -dMinMax:
				rDir = 1
		pointer.set_rot(pDirection)
#		get_node("canvas/data_ui/fps").set_text(str(OS.get_frames_per_second()))
#=====================================================

func get_winers():
	var v = score[0]
	if score.size() > 1:
		for i in range(1, score.size()):
			if v < score[i]:
				v = score[i]
	var up_score = []
	for i in range(global.score.size()):
		up_score.append(int(v == score[i]))
	return(up_score)



func fire_pressed():
	if to_restart:
		get_tree().reload_current_scene()
		
	
	var trows_left = 0
	for t in throws:
		trows_left += t
	if trows_left <= 0:
		return
	state += 1
	if state == 2:
		fire()
	elif state == 1:
		get_node("ui/pointer").show()

func fire():
	state = 0
	throws[team] -= 1
	get_node("canvas/data_ui/player" + str(team)).set_trows(throws[team])
	if throws[team] < 0:
		throws[team] = 0
	spawn_penguin()
	if global.score.size() > 1:
		get_node("canvas/data_ui/player" + str(team)).play_anim("out")
	team += 1
	if team > (global.score.size() - 1):
		team = 0
	get_node("camera_position/cam_anim").play("fire")
	no_control = true
	
	var throws_left = 0
	for t in throws:
		throws_left += t
	if throws_left <= 0:
		go = true
		get_node("canvas/score_anim").play("total_score")
#		$camera_position/Camera/data_ui/total_score_tab/score_anim.play("total_score")


	get_node("ui/pointer").hide()
	get_node("ui/power").hide()

func spawn_penguin():
	var penguin = penguin_obj.instance()
	var r = -pointer.get_rot()
	penguin.set_rot(-r)
	penguin.set_linear_velocity(Vector2(cos(r), sin(r)).normalized() * power * 22)
	penguin.set_team(team)
	penguin.set_color(global.team_color[team])
	get_node("game_field/penguins").add_child(penguin)
	var flag = flag_obj.instance()
	flag.penguin = penguin
	flag.set_color(global.team_color[team])
	get_node("ui/flags").add_child(flag)
	flag.set_pos(penguin.get_pos())

func _on_fire_button_button_down():
	if !no_control:
		fire_pressed()

func _on_cam_anim_finished():
	no_control = false
	if !go:
		get_node("ui/power").show()
	if global.score.size() > 1:
		get_node("canvas/data_ui/player" + str(team)).play_anim("in")
	
func resizer():
	screen_size = get_tree().get_root().get_visible_rect().size
	var ratio = screen_size.x/screen_size.y
	screen_scale = Vector2(global.original_screen_size.x / screen_size.x, global.original_screen_size.y / screen_size.y)
	var horizontal = ratio * global.original_screen_size.y 
	get_node("camera_position/Camera").zoom = Vector2(screen_scale.y, screen_scale.y)
	get_node("canvas/data_ui").set_scale(Vector2(1 / screen_scale.y, 1 / screen_scale.y))
	get_node("canvas/data_ui").set_size(screen_size * screen_scale.y)
	
