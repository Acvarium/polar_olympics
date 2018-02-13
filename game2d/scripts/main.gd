extends Node2D
var penguin_obj = load("res://objects/penguin.tscn")
var flag_obj = load("res://objects/flag.tscn")
var peng_ico_obj = load("res://objects/peng_ico.tscn")
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
var max_throw = 1
var team = 0
var go = false
var score = []
var touch = false
var touch_mode = false
var pushed = false
var data_ui
var peng_ico_step = 37
var no_control = false
var game_stop = false
var to_restart = false

func _ready():
	global = get_node("/root/global")
	power = min_power
	get_tree().get_root().connect("size_changed", self, "resizer")
	pointer = $ui/pointer
	target_pos = $game_field/target.global_position
	resizer()
	for i in range(global.score.size()):
		throws.append(max_throw)
		score.append(0)
	data_ui = $camera_position/Camera/data_ui
	for p in range(global.score.size()):
		if data_ui.has_node("player" + str(p)):
			data_ui.get_node("player" + str(p)).show()
			data_ui.get_node("player" + str(p) + "/under").self_modulate = global.team_color[p]
#			$game_field/ice.
			
			for i in range(max_throw):
				var p_ico = peng_ico_obj.instance()
				data_ui.get_node("player" + str(p) + "/p").add_child(p_ico)
				p_ico.position = Vector2()
				var sine = 1
				if (p % 2):
					sine = -1
				p_ico.position.x = i * peng_ico_step * sine
				p_ico.name = "p_ico" + str(i)

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
	elif state == 1:
		pDirection += pSpeed * rDir * delta
		if rDir == 1:
			if pDirection > dMinMax:
				rDir = -1
		else:
			if pDirection < -dMinMax:
				rDir = 1
		pointer.rotation = pDirection

func fire():
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

func _input(event):
	if pushed:
		return
	if no_control:
		return
	if (!touch_mode and Input.is_action_just_pressed("fire") or event is InputEventScreenTouch):
		if to_restart:
			get_tree().reload_current_scene()
		var tr = 0
		for t in throws:
			tr += t
		if tr <= 0:
			return
		pushed = true
		$timers/tap.start()
		if event is InputEventScreenTouch:
			touch_mode = true
			if event.index != 0:
				return
			if event.pressed:
				if touch:
					return
			else:
				touch = false
				return

		state += 1
		if state == 2:
			fire()
		elif state == 1:
			$ui/pointer.show()

func resizer():
	screen_size = get_tree().root.get_visible_rect().size
	var ratio = screen_size.x/screen_size.y
	screen_scale = Vector2(global.original_screen_size.x / screen_size.x, global.original_screen_size.y / screen_size.y)
	var horizontal = ratio * global.original_screen_size.y 
	$camera_position/Camera.zoom = Vector2(screen_scale.y, screen_scale.y)
	$camera_position/Camera/data_ui.margin_right = horizontal

func _on_tap_timeout():
	pushed = false

func _on_cam_anim_animation_finished( anim_name ):
	no_control = false
	if global.score.size() > 1:
		data_ui.get_node("player" + str(team) + "/icon_anim").play("in")
