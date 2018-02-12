extends Node2D
var penguin_obj = load("res://objects/penguin.tscn")
var flag_obj = load("res://objects/flag.tscn")
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
var max_throw = 6
var team = 0
var go = false
var score = []
var touch = false
var touch_mode = false
var pushed = false

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
	var ss = ''
	for t in throws:
		ss += str(t) + ' '
	$ui/throws.text = ss
	ss = ''
	for s in global.score:
		ss += str(s) + ':'
	$ui/total_score.text = ss

func _process(delta):
	$ui/fps.text = str(Engine.get_frames_per_second())
	if go:
		var sl = true
		for p in $game_field/penguins.get_children():
			if !p.sleeping:
				sl = false
		if sl:
			get_tree().reload_current_scene()

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
	for i in range(score.size()):
		score[i] = 0
	for f in $ui/flags.get_children():
		var peng = f.penguin
		if peng.score > 0:
			f.position = peng.global_position
			f.get_node("sprite/label").text = str(peng.score)
		score[peng.team] += peng.score
		
		f.visible = peng.score > 0
	var ss = ''
	for s in score:
		ss += str(s) + '__'
	$ui/score.text = ss
		

func fire():
	state = 0
	throws[team] -= 1
	if throws[team] < 0:
		throws[team] = 0
	var ss = ''
	for t in throws:
		ss += str(t) + ' '
	$ui/throws.text = ss
	spawn_penguin()
	team += 1
	if team > (global.score.size() - 1):
		team = 0
	$ui/team.text = str(team)
	
func spawn_penguin():
	var penguin = penguin_obj.instance()
	var r = pointer.rotation
	penguin.rotation = r
	penguin.linear_velocity = Vector2(cos(r), sin(r)).normalized() * power * 25
	penguin.set_team(team)
	penguin.set_color(global.team_color[team])
	$game_field/penguins.add_child(penguin)
	var flag = flag_obj.instance()
	flag.penguin = penguin
	flag.position = penguin.global_position
	flag.set_color(global.team_color[team])
	$ui/flags.add_child(flag)
#	flag.hide()

func _input(event):
	if pushed:
		return
	if (!touch_mode and Input.is_action_just_pressed("fire") or event is InputEventScreenTouch):
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
		var tr = 0
		for t in throws:
			tr += t
		if tr <= 0:
			go = true
			$ui/game_over.show()
			return
		state += 1
		if state == 2:
			fire()
		elif state == 1:
			$ui/pointer.show()

func resizer():
	screen_size = get_tree().root.get_visible_rect().size
	screen_scale = global.original_screen_size.x / screen_size.x
	$camera_position/Camera.zoom = Vector2(screen_scale, screen_scale)
	$camera_position.position = Vector2(global.original_screen_size.x / 2, global.original_screen_size.y / 2)
	

func _on_go_timeout():
	
	pass # replace with function body

func _on_tap_timeout():
	pushed = false
