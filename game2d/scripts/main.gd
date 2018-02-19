extends Node2D
var penguin_obj = load("res://objects/penguin.tscn")
var flag_obj = load("res://objects/flag.tscn")
var peng_ico_obj = load("res://objects/peng_ico.tscn")
var bonus_fish_obj = load("res://objects/bonus_fish.tscn")
var swim_fish_obj = load("res://objects/swim_fish.tscn")
var global
var screen_size = Vector2()
var pDirection = 0
var pSpeed = 2
var dMinMax = 1
var state = 0
var rDir = 1
var power_speed = 150
var max_power = 90
var min_power = 5
var power = 0
var pointer
var target_pos = Vector2()
var target_radius = 384.0
var screen_scale = 1
var throws = []
var max_throw
var team = 0
var go = false
var data_ui
var peng_ico_step = 37
var no_control = false
var game_stop = false
var to_restart = false
var bonus_score = []
var score = []
var min_pos = Vector2(-300, -800)
var max_pos = Vector2(2700, 800)
var to_exit = false
var button_pressed = false
var mouse_over_ui = false
var avatars = []
var test_velocity = 1000
var pc_velocoty = 960
var pc_angle = 0
var rand_twist = 0
var pc_fire_allow = false
var rand_power = 0
var fire_timeout = false

func _ready():
	randomize()
	global = get_node("/root/global")
	global.go_to_next = 0
	max_throw = global.max_throw
	var p = 0
	for i in range(global.selected_players.size()):
		if global.selected_players[i] > 0:
			var p_name = "camera_position/Camera/data_ui/player" + str(p)
			get_node(p_name + "/icon").frame = global.selected_players[i]
			get_node(p_name + "/under/label").text = global.player_name[i]
			avatars.append(global.selected_players[i])
			p += 1
	power = min_power
	get_tree().get_root().connect("size_changed", self, "resizer")
	pointer = $ui/pointer
	target_pos = $game_field/target.global_position
	resizer()
	var wss = ''
	for i in range(global.score.size()):
		wss += str(global.score[i])
		if i < (global.score.size() - 1):
			wss += ":"
	$camera_position/Camera/data_ui/t_score.text = wss
	if avatars[0] == 23:
		rand_fire(2)
	$ui/vel.text = str(test_velocity)

#add fishes
#	for i in range(20):
#		var swim_fish = swim_fish_obj.instance()
#		swim_fish.position = Vector2(randf() * max_pos.x + min_pos.x, randf() * max_pos.y + min_pos.y)
#		swim_fish.rotation = (randf() * PI * 2)
#		var f_scale = randf() * 0.2 + 0.9
#		swim_fish.scale = Vector2(f_scale, f_scale)
#		var transp = randf() * 0.5 + 0.5
#		swim_fish.modulate = Color(1, 1, 1, transp)
#		$game_field/fishes.add_child(swim_fish)

	for i in range(global.score.size()):
		throws.append(max_throw)
		score.append(0)
		bonus_score.append(0)
	data_ui = $camera_position/Camera/data_ui
	for p in range(global.score.size()):
		if data_ui.has_node("player" + str(p)):
			data_ui.get_node("player" + str(p)).show()
			data_ui.get_node("player" + str(p) + "/under/label").self_modulate = global.team_color[p]
			if p == 0:
				data_ui.get_node("player" + str(p) + "/under/label").add_color_override("font_color", Color(0.72,0.72,0.72,1) )

			for i in range(max_throw):
				var p_ico = peng_ico_obj.instance()
				data_ui.get_node("player" + str(p) + "/p").add_child(p_ico)
				p_ico.position = Vector2()
				var sine = 1
				if (p % 2):
					sine = -1
				p_ico.position.x = i * peng_ico_step * sine
				p_ico.name = "p_ico" + str(i)
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST or what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		if to_exit:
			get_node("/root/global").goto_scene("res://scenes/menu.tscn")
		else:
			to_exit = true
			$camera_position/Camera/data_ui/exit_message/exit_mess_anim.play("mess")

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

func _process(delta):
	for i in range(score.size()):
		score[i] = 0
	for f in $ui/flags.get_children():
		var peng = f.penguin
		if peng.score > 0:
			f.position = peng.global_position
			f.get_node("sprite/label").text = str(peng.score)
		score[peng.team] += peng.score
		f.visible = peng.score > 0
	for i in range(score.size()):
		score[i] += bonus_score[i]
		var node_name = "player" + str(i)
		if data_ui.has_node(node_name):
			data_ui.get_node(node_name + "/under/score").text = str(score[i])
		
	$camera_position/Camera/data_ui/fps.text = str(Engine.get_frames_per_second())
	if go:
		var sl = true
		for p in $game_field/penguins.get_children():
			if !p.sleeping:
				sl = false
		if sl and !game_stop:
			game_stop = true
			var winers = get_winers()
			var wss = ''
			for i in range(winers.size()):
				global.score[i] += winers[i]
				wss += str(global.score[i])
				if i < (global.score.size() - 1):
					wss += ":"
			$camera_position/Camera/data_ui/t_score.text = wss
			var score_label = $camera_position/Camera/data_ui/total_score_tab/total_score
			score_label.text = wss
			$camera_position/Camera/data_ui/total_score_tab/score_anim.play("show_score")
			to_restart = true
			
	if state == 0:
		power += power_speed * rDir * delta
		if power > max_power:
			rDir = -1
		if power < min_power:
			rDir = 1
		$ui/power.value = power
		if avatars[team] == 23 and pc_fire_allow:
			$ui/vel2.text = str(int(abs((power * 22) - pc_velocoty)))
			if abs((power * 22) - pc_velocoty + rand_power) < 10:
				pc_fire_allow = false
				fire_pressed()
				rand_twist =  randf() * 0.2 - 0.1
	elif state == 1:
		pDirection += pSpeed * rDir * delta
		if rDir == 1:
			if pDirection > dMinMax:
				rDir = -1
		else:
			if pDirection < -dMinMax:
				rDir = 1
		pointer.rotation = pDirection
		if avatars[team] == 23 and pc_fire_allow:
			if abs(pDirection - pc_angle + rand_twist) < 0.01:
				pass
				$ui/vel2.text = str(pDirection)
				pc_fire_allow = false
				fire_pressed()

func bonus(t, value, type):
	if type == 'fish':
		$audio/coin.play()
		bonus_score[t] += value

func test_fire():
	var penguin = penguin_obj.instance()
	var r = 0
	penguin.rotation = r
	penguin.linear_velocity = Vector2(test_velocity,0)
	penguin.set_team(team)
	penguin.set_color(global.team_color[team])
	$game_field/penguins.add_child(penguin)
	var flag = flag_obj.instance()
	flag.penguin = penguin
	flag.position = penguin.global_position
	flag.set_color(global.team_color[team])
	$ui/flags.add_child(flag)

func fire():
#	$camera_position/Camera/data_ui/red_button.hide()
	state = 0
	throws[team] -= 1
	if throws[team] < 0:
		throws[team] = 0
	data_ui.get_node("player" + str(team) + "/p/p_ico" + str(throws[team])).hide()
	spawn_penguin()
	if global.score.size() > 1:
		data_ui.get_node("player" + str(team) + "/icon_anim").play("out")
	team += 1
	if team > (global.score.size() - 1):
		team = 0
	$camera_position/cam_anim.play("fire")
	no_control = true
	var tr = 0
	for t in throws:
		tr += t
	if tr <= 0:
		go = true
		$camera_position/Camera/data_ui/total_score_tab/score_anim.play("total_score")
	$ui/pointer.hide()
	$ui/power.hide()
	
func spawn_penguin():
	var penguin = penguin_obj.instance()
	var r = pointer.rotation
	penguin.rotation = r
	penguin.linear_velocity = Vector2(cos(r), sin(r)).normalized() * power * 22
	penguin.set_team(team)
	penguin.set_color(global.team_color[team])
	$game_field/penguins.add_child(penguin)
	var flag = flag_obj.instance()
	flag.penguin = penguin
	flag.position = penguin.global_position
	flag.set_color(global.team_color[team])
	$ui/flags.add_child(flag)

func add_bonus_fish():
	$audio/ten.play()
	$game_field/bonus/bonus_anim.play("ten")
	var ref = $game_field/bonus/ref
	var min_pos = $game_field/bonus/ref.rect_position
	var offset = $game_field/bonus/ref.rect_size
	var bonus_pos = Vector2()
	bonus_pos.x = randf() * offset.x + min_pos.x
	bonus_pos.y = randf() * offset.y + min_pos.y
	var fish = bonus_fish_obj.instance()
	fish.global_position = bonus_pos
	$game_field/bonus.add_child(fish)

func _input(event):
#	if Input.is_action_just_pressed("clear_peng"):
#		for p in $game_field/penguins.get_children():
#			p.queue_free()
#		for f in $ui/flags.get_children():
#			f.queue_free()
#	if Input.is_action_just_pressed("test_fire"):
#		test_fire()
#		return
#	if Input.is_action_just_pressed("w_up"):
#		test_velocity += 5
#		$ui/vel.text = str(test_velocity)
#	elif Input.is_action_just_pressed("w_down"):
#		test_velocity -= 5
#		$ui/vel.text = str(test_velocity)
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if no_control:
		return
	
	if Input.is_action_just_pressed("fire"):
		fire_pressed()

func rand_fire(delay):

	var rand_time = randf() * 2
	$timers/rand_fire.wait_time = rand_time + delay
	$timers/rand_fire.start()

func fire_pressed():
	if fire_timeout:
		return
	fire_timeout = true
	$timers/fire_timeout.start()
	if to_restart:
		get_tree().reload_current_scene()
	var tr = 0
	for t in throws:
		tr += t
	if tr <= 0:
		return
	state += 1
	if state == 2:
		fire()
	elif state == 1:
		$ui/pointer.show()
	if avatars[team] == 23 and state == 1:
		rand_fire(0.5)

func resizer():
	screen_size = get_tree().root.get_visible_rect().size
	var ratio = screen_size.x/screen_size.y
	screen_scale = Vector2(global.original_screen_size.x / screen_size.x, global.original_screen_size.y / screen_size.y)
	var horizontal = ratio * global.original_screen_size.y 
	$camera_position/Camera.zoom = Vector2(screen_scale.y, screen_scale.y)
	$camera_position/Camera/data_ui.margin_right = horizontal

func _on_cam_anim_animation_finished( anim_name ):
	no_control = false
	if !go:
		$ui/power.show()
		if avatars[team] == 23:
			rand_fire(0.5)
#		$camera_position/Camera/data_ui/red_button.show()
	if global.score.size() > 1:
		data_ui.get_node("player" + str(team) + "/icon_anim").play("in")

func _on_start_game_timeout():
	$audio/start.play()

func _on_exit_mess_anim_animation_finished( anim_name ):
	to_exit = false

func _on_menu_button_pressed():
	button_pressed = true
	if to_exit:
		get_node("/root/global").goto_scene("res://scenes/menu.tscn")
	else:
		to_exit = true
		$camera_position/Camera/data_ui/exit_message/exit_mess_anim.play("mess")

func _on_button_pressed_timeout():
	button_pressed = false

func _on_fire_button_button_down():
	if avatars[team] == 23 and !to_restart:
		return
	fire_pressed()

func _on_rand_fire_timeout():
	pc_fire_allow = true
	rand_power = randf() * 300 - 150

func _on_fire_timeout_timeout():
	fire_timeout = false 
