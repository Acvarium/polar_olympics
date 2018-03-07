extends Node2D
var screen_size = Vector2()
var screen_scale = Vector2()
var penguin_obj = load("res://objects/penguin.tscn")
var bonus_fish_obj = load("res://objects/bonus_fish.tscn")
var bonus_effect_obj = load("res://objects/bonus_effect.tscn")
var fall_pos_obj = load("res://objects/fall_pos.tscn")

var global
var state = 0
var avatars = []
var throws = []
var score = []
var bonus_score = []
var max_throw = 1
var team = 1
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
var button_pressed = false
var to_exit = false
var fire_timeout = false
var camera_animation = 'fire'
var bonus10_on = true
var tutorial = 1
var v_slide_allow = false
var auto_restart = false
var pressed_time

var mouse_down = false
var aim = false
var power_multiplier = 2.5
var fire_velocity = Vector2()
var to_fire = false

var pc_fire_allow = false
var state_velocitys = [900, 1590, -1]
var state_angles = [0, 0.78, 0]
var state_shifts = [[300,0.2],[300,0.2],[300,0.05]]
var peng_id = 0
var peng_teams = []
var peng_score = []
var default_target = true
var p_num = 0
var star_num = 0
var star_score = 3
var level_max_score = 0
var draw_layer
var min_len = 100
var level_tutorial = 1
var control_type = 1
var bonus_left = 0
var start_pos = Vector2()

func _ready():
	
	draw_layer = get_node("draw")
	set_process_input(true)
	global = get_node("/root/global")
	team = global.team
	pointer = get_node("game_field/point/pointer")
	resizer()
	get_tree().get_root().connect("size_changed", self, "resizer")
	target_pos = get_node("game_field/target").get_global_pos()
	control_type = global.control_type
	geme_setup()
	set_process(true)
#	
	get_node("canvas/data_ui/hello_button/hello/rateit").set_bbcode(tr("RATEIT"))
	if global.single:
		control_type = 1
		load_level(global.next_level)
#		get_node("canvas/data_ui/player0").hide()
		get_node("canvas/data_ui/level_score").show()
	else:
		get_node("canvas/data_ui/replay_button").hide()
	var score_sum = 0
	for s in global.score:
		score_sum += s
	var single_tut_on = false
	
	if global.single:
		if global.level_num == 0:
			single_tut_on = true
	if global.tutorial != 0 and ((!global.single and control_type == 1 and score_sum == 0) or single_tut_on):
		no_control = true
		get_node("tutorial").play("tutorial" + str(level_tutorial))
		get_node("game_field/effects/hand").show()
	else:
		get_node("game_field/effects/hand").hide()
		if has_node("game_field/penguins/tut_peng"):
			get_node("game_field/penguins/tut_peng").queue_free()
	if is_bot_move() and global.tutorial == 0 and !global.single:
		get_node("timers/bot_fire").start()
		
	if v_slide_allow and !is_bot_move():
		get_node("game_field/point/arrows").show()
	else:
		get_node("game_field/point/arrows").hide()
	
func load_level(l):
	var level = load(l).instance()
	get_node("game_field/levels").add_child(level)

func add_splash(pos):
	var fall_pos = fall_pos_obj.instance()
	get_node("game_field/effects").add_child(fall_pos)
	fall_pos.set_global_pos(pos)
	fall_pos.set_scale(Vector2(0.6,0.6))
	get_node("sounds/splash").play()

func geme_setup():
	for i in range(4):
		get_node("canvas/data_ui/player" + str(i)).hide()
	max_throw = global.max_throw
	var total_score_str = ''
	throws = []
	for i in range(global.score.size()):
		throws.append(max_throw)
		score.append(0)
		bonus_score.append(0)
		avatars.append(global.selected_players[i])
#		if global.single:
#			get_node("canvas/data_ui/player" + str(i)).play_anim("out")
		get_node("canvas/data_ui/player" + str(i)).show()
		get_node("canvas/data_ui/player" + str(i)).set_team_color(global.team_color[i])
		get_node("canvas/data_ui/player" + str(i)).set_trows(max_throw)
		get_node("canvas/data_ui/player" + str(i)).set_team_avatar(global.selected_players[i])
		get_node("canvas/data_ui/player" + str(i)).set_team_name(global.player_name[i])
		if i == 0:
			get_node("canvas/data_ui/player" + str(i)).set_team_color(Color(0.7,0.7,0.7,1))
		total_score_str += str(global.score[i])
		if i < (global.score.size() - 1):
			total_score_str += ":"
	get_node("canvas/data_ui/total_score").set_text(total_score_str)
	if start_pos != Vector2():
		get_node("game_field/point").set_global_pos(start_pos)
	if global.single:
		get_node("canvas/data_ui/player0").play_anim("single")
		get_node("canvas/data_ui/player0").set_level(global.level_num)

func fall(p_path,hole_path):
	var p = get_node(p_path)
	var hole = get_node(hole_path)
	var vel = p.get_linear_velocity()
	var p_pos = p.get_global_pos()
	var p_rot = p.get_global_rot()
	var per = p.get_parent()
	p.set_collision_mask_bit(1,false)
	p.set_layer_mask_bit(1,false)
	per.remove_child(p)
	hole.add_child(p)
	p.set_global_pos(p_pos)
	p.set_global_rot(p_rot)

	get_node("sounds/splash").play()
#------------------------------
func _input(event):
	if event.is_action_pressed("slide_control"):
		v_slide_allow = !v_slide_allow
		if v_slide_allow and !is_bot_move():
			get_node("game_field/point/arrows").show()
		else:
			get_node("game_field/point/arrows").hide()
#			
	if event.is_action_pressed("lmb"):
		mouse_down = true
	elif event.is_action_released("lmb"):
		
		get_node("game_field/point/arrows/up").set_modulate(Color(1,1,1))
		get_node("game_field/point/arrows/down").set_modulate(Color(1,1,1))
		aim = false
		mouse_down = false
		draw_layer.lines = []
		draw_layer.update()
		var dist = get_node("game_field/point").get_global_pos().distance_to(get_global_mouse_pos())
		if to_fire and dist > min_len:
			if get_global_mouse_pos().x > 200:
				fire()
		to_fire = false
		
	if event.is_action_pressed("quit"):
		global.game_quit()

func stars_on():
	for i in range(3):
		get_node("canvas/data_ui/single_score/star" + str(i)).star_reset()
		
	star_num = 0
	star_score = int(score[0] / (level_max_score / 3.0))
	if star_score == 3 and score[0] < level_max_score:
		star_score = 2
	if star_score > 0:
		get_node("canvas/data_ui/single_score/buttons/play_button").show()
	get_node("canvas/data_ui/single_score/star_timer").start()

func bonus_counter(b):
	level_max_score += b
	bonus_left += b
	var ss = str(score[team]) + '/' + str(level_max_score)
	get_node("canvas/data_ui/level_score/score").set_text(ss)

func remove_obj(r):
	if r == "target":
		get_node("game_field/target").queue_free()
	elif r == "walls":
		for w in get_node("game_field/blocks").get_children():
			w.queue_free()
		for s in get_node("game_field/shadows").get_children():
			s.queue_free()
	elif r == "top_score":
		get_node("canvas/data_ui/total_score").hide()
		
#========================================================================
func _process(delta):
	if mouse_down and aim:
		var col = Color(0,1,0)
		var pow_vec = get_node("game_field/point").get_global_pos() - get_global_mouse_pos() 
		var time_r = (OS.get_ticks_msec() - pressed_time) * 0.00001
		var rand_shift = Vector2(randf() - 0.5, 2*(randf() - 0.5))
		var pow_vec_r = pow_vec + (rand_shift * pow_vec.length()*time_r)
		pow_vec_r = pow_vec
		if get_global_mouse_pos().x < 200 and get_global_mouse_pos().y > 160 and get_global_mouse_pos().y < 900:
			if v_slide_allow:
				var point_pos = get_node("game_field/point").get_global_pos()
				point_pos.y = get_global_mouse_pos().y
				get_node("game_field/point").set_global_pos(point_pos)
				get_node("game_field/point/arrows/up").set_modulate(Color(0,1,0.2))
				get_node("game_field/point/arrows/down").set_modulate(Color(0,1,0.2))
			get_node("game_field/point/power_arrow").hide()
				
		elif pow_vec.length() > min_len and get_global_mouse_pos().x > 200:
			get_node("canvas/data_ui/vel").set_text(str(time_r))
			get_node("game_field/point/arrows/up").set_modulate(Color(1,1,1))
			get_node("game_field/point/arrows/down").set_modulate(Color(1,1,1))
			get_node("game_field/point/power_arrow").show()
			get_node("game_field/point/power_arrow").set_rot(pow_vec_r.angle() + PI/2)
			get_node("game_field/point/power_arrow/ring").set_pos(Vector2(pow_vec_r.length() * 3.36,0))
			get_node("game_field/point/power_arrow/arrow").set_size(Vector2(pow_vec_r.length() * 2 + 75, 136))
		else:
			get_node("game_field/point/power_arrow").hide()
#		fire_velocity = get_global_mouse_pos() - get_node("game_field/point").get_global_pos()
		fire_velocity = -pow_vec_r
		
	if go:
		var all_sleep = true
		for p in get_node("game_field/penguins").get_children():
			if !p.is_sleeping():
				all_sleep = false
		var score_end = false
		if global.single:
			score_end = score[0] >= level_max_score or bonus_left <= 0
		if (all_sleep or score_end) and !game_stop:
			game_stop = true
			var winers = get_winers()
			var total_score_str = ''
			for i in range(winers.size()):
				global.score[i] += winers[i]
				if winers[i] > 0 and !global.single:
					get_node("canvas/data_ui/player" + str(i)).play_anim("in")
				total_score_str += str(global.score[i])
				if i < (global.score.size() - 1):
					total_score_str += ":"
			get_node("canvas/data_ui/total_score_tab/score").set_text(total_score_str)
			get_node("canvas/data_ui/total_score").set_text(total_score_str)
			if global.single:
				get_node("canvas/score_anim").play("single_score")
			else:
				get_node("canvas/score_anim").play("show_score")
			to_restart = true


func bonus(t, value, type, pos):
	bonus_score[t] += value
	bonus_left -= value
	var effect = bonus_effect_obj.instance()
	if type == 'hole':
		effect.set_timeout(0.5)
	effect.set_bonus_score(value)
	effect.set_effect_type('fish')
	get_node("game_field/effects").add_child(effect)
	effect.set_global_pos(pos)
	update_team_score(t)
	if global.single and bonus_left <= 0:
		throws[team] = 0
		go = true

func add_bonus_fish():
	if go or !bonus10_on:
		return
	var effect = bonus_effect_obj.instance()
	effect.set_bonus_score(10)
	effect.set_effect_type('bonus10')
	get_node("game_field/effects").add_child(effect)
	effect.set_global_pos(target_pos)
#	update_team_score(t)
	var ref = get_node("game_field/bonus/ref")
	var min_pos = ref.get_rect().pos
	var offset = ref.get_size()
	var bonus_pos = Vector2()
	bonus_pos.x = randf() * offset.x + min_pos.x
	bonus_pos.y = randf() * offset.y + min_pos.y
	var fish = bonus_fish_obj.instance()
	fish.set_global_pos(bonus_pos)
	get_node("game_field/bonus").add_child(fish)

func rand_fire(delay):
	var rand_time = randf() * 1.8
	get_node("timers/rand_fire").set_wait_time(rand_time + delay)
	get_node("timers/rand_fire").start()

func  bot_move():
	var rand_value = randf()
	var bot_state = 0
	var bot_power = 0
	var bot_angle = 0
	get_node("game_field/point").set_pos(Vector2())
	if rand_value < 0.6 or throws[team] == 1:
#Постріл на вибивання
		var hi_score_team = team
		for i in range(score.size()):
			if team == i:
				break
			if score[i] > score[hi_score_team]:
				hi_score_team = i
		if hi_score_team != team and (score[hi_score_team] - score[team]) > 5:
			bot_state = 2
			var peng
			var p_hi_score = 0
			for p in get_node("game_field/penguins").get_children():
				if p.team == hi_score_team and p.score > p_hi_score:
					p_hi_score = p.score
					peng = p
			if peng:
				var d = Vector2().distance_to(peng.get_pos())
				bot_power = d * 1.32
				bot_angle = peng.get_pos().angle() - PI/2
#Звичайний постріл в центер мішені
#Потрібно переробити
	if bot_state != 2:
		if rand_value > 0.9:
			bot_state = 1
		bot_power = state_velocitys[bot_state]
		var rand_dir = randi()%2
		if rand_dir == 0:
			rand_dir = -1
		
		bot_angle = state_angles[bot_state]
		if bot_state == 1:
			bot_angle *= rand_dir
	var rand_power = randf() * state_shifts[bot_state][0] - state_shifts[bot_state][0]/2
	var rand_twist =  randf() * state_shifts[bot_state][1] - state_shifts[bot_state][1]/2
	power = bot_power + rand_power
	pDirection = -(bot_angle + rand_twist)
	fire()

func get_winers():

	var j = global.team
	var v = score[j]
	if score.size() > 1:
		for i in range(1, score.size()):
			j += 1
			if j > (score.size() - 1):
				j = 0
			if v <= score[j]:
				v = score[j]
				global.team = j
			
	var up_score = []
	for i in range(global.score.size()):
		up_score.append(int(v == score[i]))
	if global.single:
		global.team = 0
	return(up_score)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if to_exit:
			get_node("/root/global").goto_scene("res://scenes/menu.tscn")
		else:
			to_exit = true
			get_node("canvas/data_ui/exit_mess/exit_anim").play("mess")
func fire():
	get_node("game_field/point/power_arrow").hide()
	get_node("timers/bot_emergency_triger").stop()
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
	get_node("camera_position/cam_anim").play(camera_animation)
	no_control = true
	get_node("game_field/point").hide()
	
	var throws_left = 0
	for t in throws:
		throws_left += t
	if throws_left <= 0:
		go = true
		if !global.single:
			get_node("canvas/score_anim").play("total_score")

func spawn_penguin():
	var penguin = penguin_obj.instance()
	penguin.set_name("penguin_" + str(p_num))
	p_num += 1
	
	
	if is_bot_move() or control_type == 0:
		var r = pDirection
		penguin.set_vel(Vector2(cos(r), sin(r)).normalized() * power)
	else:
		penguin.set_vel(fire_velocity * power_multiplier)
	penguin.set_team(team)
	peng_teams.append(team)
	peng_score.append(0)
	penguin.set_color(global.team_color[team])
	penguin.set_id(peng_id)
	peng_id += 1
	get_node("game_field/penguins").add_child(penguin)
	penguin.set_global_pos(get_node("game_field/point").get_global_pos())
	if global.volume_scale > 0:
		get_node("sounds/yahoo").play("yahoo")
	if global.single:
		update_team_score(0)

func update_peng_score(id, value):
	peng_score[id] = value
	update_team_score(peng_teams[id])
	
func update_team_score(t):
	score[t] = bonus_score[t]
	if !global.single:
		for i in range(peng_score.size()):
			if peng_teams[i] == t:
				score[peng_teams[i]] += peng_score[i]
		get_node("canvas/data_ui/player" + str(t)).set_team_score(score[t])
	else:
		var penalty = 0
		if p_num > 1:
			penalty = 2 * (p_num - 1)
		score[t] -= penalty
		var ss = str(score[0]) + '/' + str(level_max_score)
		get_node("canvas/data_ui/level_score/score").set_text(ss)
		if score[0] >= level_max_score:
			go = true
		
func _on_fire_button_button_down():
	var score_sum = 0
	for s in global.score:
		score_sum += s
	if score_sum > 2 and randf() < 0.6:
		get_node("canvas/data_ui/hello_button").show()
		get_node("canvas/data_ui/total_score_tab").hide()
	else:
		get_tree().reload_current_scene()

func is_bot_move():
	return avatars[team] == 23 and !global.single

func _on_cam_anim_finished():
	set_process(true)
#переписати підрахунок кидків, що залишились
	var trows_left = 0
	for t in throws:
		trows_left += t
	if trows_left > 0:
		no_control = false
		get_node("game_field/point").show()
		if v_slide_allow and !is_bot_move():
			get_node("game_field/point/arrows").show()
		else:
			get_node("game_field/point/arrows").hide()
			
	if is_bot_move():
		get_node("timers/bot_fire").start()
	if global.score.size() > 1 and !go and !global.single:
		get_node("canvas/data_ui/player" + str(team)).play_anim("in")
	
func resizer():
	screen_size = get_tree().get_root().get_visible_rect().size
	var ratio = screen_size.x/screen_size.y
	screen_scale = Vector2(global.original_screen_size.x / screen_size.x, global.original_screen_size.y / screen_size.y)
	var horizontal = ratio * global.original_screen_size.y
	get_node("camera_position/Camera").zoom = Vector2(screen_scale.x, screen_scale.x)
	get_node("canvas/data_ui").set_scale(Vector2(1 / screen_scale.y, 1 / screen_scale.y))
	get_node("canvas/data_ui").set_size(screen_size * screen_scale.y)
	
func _on_rand_fire_timeout():
	pc_fire_allow = true

func _on_menu_button_pressed():
	button_pressed = true
	if to_exit:
		get_node("/root/global").goto_scene("res://scenes/menu.tscn")
	else:
		to_exit = true
		get_node("canvas/data_ui/exit_mess/exit_anim").play("mess")

func _on_exit_anim_finished():
	to_exit = false

func _on_fire_timeout_timeout():
	fire_timeout = false

func _on_star_timer_timeout():
	if global.stages_locks[global.level_num] < star_score:
		global.stages_locks[global.level_num] = star_score
	if global.level_num < global.MAX_STAGE:
		if global.stages_locks[global.level_num + 1] < 0:
			global.stages_locks[global.level_num + 1] = 0
	global.worlds_locks[int((global.level_num + 1) / 16)] = 0
	global.set_selected = (int((global.level_num + 1) / 16)) * 16
	if star_num < star_score:
		get_node("canvas/data_ui/single_score/star" + str(star_num)).star_on(star_num)
		get_node("canvas/data_ui/single_score/star_timer").start()
		star_num += 1

func _on_score_anim_finished():
	if global.single:
		stars_on()
		to_exit = true
	if auto_restart:
		get_node("timers/autorestart").start()

func _on_play_button_pressed():
	global.select_next_level(1)
	get_tree().reload_current_scene()

func _on_replay_button_pressed():
	get_tree().reload_current_scene()

func _on_aim_button_button_down():
	if is_bot_move() and !to_restart:
		return
	if !no_control:
		pressed_time = OS.get_ticks_msec()
		aim = true
		to_fire = true

func _on_tutorial_finished():
	no_control = false
	if is_bot_move():
		get_node("timers/bot_fire").start()
	if has_node("game_field/penguins/tut_peng"):
		get_node("game_field/penguins/tut_peng").queue_free()

func _on_hello_button_pressed():
	get_node("canvas/data_ui/hello_button").hide()
	get_tree().reload_current_scene()

func _on_rate_button_pressed():
	if OS.get_name() == "Android":
		OS.shell_open("http://play.google.com/store/apps/details?id=org.godotengine.polarcurling")
	else:
		OS.shell_open("https://acvarium.itch.io/po")
	get_node("canvas/data_ui/hello_button").hide()
	get_tree().reload_current_scene()

func _on_bot_fire_timeout():
	if throws[team] > 0:
		bot_move()

func _on_autorestart_timeout():
	get_tree().reload_current_scene()