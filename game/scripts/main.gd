extends Node
var pointer
var pDirection = 0
var rDir = 1
var pSpeed = 2
var power_speed = 150
var dMinMax = 1
var penguin_obj = load("res://objects/penguin.tscn")
var testP
var fish_obj = load("res://models/fish.tscn")
var score_cloud_obj = load("res://objects/score_cloud.tscn")
var state = 3
var max_shoot = 6
var p_team_shoot = 0
var b_team_shoot = 0
var target
var target_radius = 12.5
var max_power = 90
var min_power = 5
var power = 0
var team = 0
var global
var go = false
var any_key = false

func _ready():
#	set_physics_process(false)
	randomize()
	$UI/pControl.position = $Camera.unproject_position(Vector3())
	global = get_node("/root/global")
	var s = str(global.score[0]) + ':' +  str(global.score[1])
	$UI/game_score2.text = s
	if global.score[0] + global.score[1] <= 0:
		$UI/bears/bears_anim.play("start")
	else:
		$UI/bears/bears_anim.play("pBear")
		$sounds/applod.play()
	testP = $penguin2
	target = $target
	pointer = $Spatial/pointer
	$fishes/fish/AnimationPlayer.get_animation("fish").set_loop(true)
	for i in range(30):
		var fish = fish_obj.instance()
		fish.set_speed(randf() * 0.5 + 0.5)
		fish._set_scale(randf() * 0.2 + 1)
		fish.translation = Vector3(randf() * 180 - 30, 0, randf() * 60 - 30)
		fish.rotation = Vector3(0,randf() * PI*2, 0)
		$fishes.add_child(fish)


func dist_to_target(translation):
	translation.y = 0
	var target_trans = target.translation
	target_trans.y = 0
	var dist = target_trans.distance_to(translation)
	return dist
func score_count(distance):
	var score = 0
	if distance < target_radius:
		score = 2
	if distance < (target_radius * 0.75):
		score = 4
	if distance < (target_radius * 0.5):
		score = 6
	if distance < (target_radius * 0.25):
		score = 8
	if distance < (target_radius * 0.078125):
		score = 10
	return score
	
func fire():
	if team == 0:
		p_team_shoot +=1
		if p_team_shoot > max_shoot:
			return
		get_node("UI/pb_penguins/p" + str(max_shoot - p_team_shoot)).hide()
	else:		
		b_team_shoot +=1
		if b_team_shoot > max_shoot:
			return
		get_node("UI/bb_penguins/p" + str(max_shoot - p_team_shoot)).hide()
	$UI/pControl/power_bar.hide()
	$Spatial/pointer.hide()
	$Spatial/t.rotation = $Spatial/pointer.rotation
	$Spatial/t.show()
	$Spatial/t/throw.set_team(team)
	$Spatial/t/throw.throw()

func spawn_penguin():
	set_physics_process(true)
	var penguin = penguin_obj.instance()
	var r = pointer.rotation.y - PI/2
	penguin.rotation.y = r
	penguin.linear_velocity = Vector3(-sin(r), 0,-cos(r)).normalized() * power
	$pengs.add_child(penguin)

	var score_cloud = score_cloud_obj.instance()
	score_cloud.pOwner = penguin
	$UI/counters.add_child(score_cloud)
	score_cloud.position = $Camera.unproject_position(score_cloud.pOwner.translation)
	$camera_anim.play("fire")
	score_cloud.set_team(team)
	team += 1
	if team > 1:
		team = 0
	$Spatial/t/throw.stay()

func _input(event):
	if any_key:
#		if Input.g
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("ui_up"):
		game_over()
	if Input.is_action_just_pressed("fire"):
		state += 1
		if state == 2:
			if p_team_shoot == 0 and b_team_shoot == 0:
				$UI/bears/dir_hint.hide()
			fire()
		elif state == 1:
#			$power_cube.hide()
			if p_team_shoot == 0 and b_team_shoot == 0:
				$UI/bears/power_hint.hide()
				if global.score[0] + global.score[1] <= 0:
					if global.score[0] + global.score[1] <= 0:
						$UI/bears/dir_hint.show()
			$Spatial/pointer.show()
	
func game_over():
	var s = str(global.score[0]) + ':' +  str(global.score[1])
	$UI/game_score.text = s
	$UI/pControl/power_bar.hide()
	$Spatial/pointer.hide()
	$UI/bears/bears_anim.play("total_score")
	
func _process(delta):
	if state == 0:
		power += power_speed * rDir * delta
		if power > max_power:
			rDir = -1
		if power < min_power:
			rDir = 1
		$UI/pControl/power_bar.value = power
#		$power_cube.scale.z = power / max_power * 3
	elif state == 1:
		pDirection += pSpeed * rDir * delta
		if rDir == 1:
			if pDirection > dMinMax:
				rDir = -1
		else:
			if pDirection < -dMinMax:
				rDir = 1
#		$UI/pControl/arrow.rotation = pDirection
		pointer.rotation.y = pDirection
	else:
		set_process(false)
		
func _physics_process(delta):
	var p_team_score = 0
	var b_team_score = 0
	var all_still = true
	for score_cloud in $UI/counters.get_children():
		score_cloud.position = $Camera.unproject_position(score_cloud.pOwner.translation)
		var distance = dist_to_target(score_cloud.pOwner.translation)
		var sc = score_count(distance)
		score_cloud.update_score(sc)
		if !score_cloud.pOwner.sleeping:
			all_still = false
		if score_cloud.team == 0:
			p_team_score += sc
		else:
			b_team_score += sc
		$UI/total_score/p_team.text = str(p_team_score)
		$UI/total_score/b_team.text = str(b_team_score)
	if all_still:
		set_physics_process(false)
	if all_still and go:
		if p_team_score > b_team_score:
			global.score[0] += 1
		elif p_team_score < b_team_score:
			global.score[1] += 1
		else:
			global.score[0] += 1
			global.score[1] += 1
		go = false
		game_over()
	
func _on_camera_anim_animation_finished( anim_name ):
	pass
	if b_team_shoot >= max_shoot and p_team_shoot >= max_shoot:
		go = true
		return
	else:
		$sounds/applod.play()
	if team == 0:
		$UI/bears/bears_anim.play("pBear")
	else:
		$UI/bears/bears_anim.play("bBear")

func _on_bears_anim_animation_finished( anim_name ):
	if anim_name == "start":
		$UI/bears/bears_anim.play("pBear")
		$sounds/start.play()
	elif anim_name == "total_score":
		any_key = true
	else:
		state = 0
		set_process(true)
		power = min_power
		rDir = 1
		$UI/pControl/power_bar.show()
		power = min_power
		$Spatial/pointer.hide()
		if p_team_shoot == 0 and b_team_shoot == 0:
			if global.score[0] + global.score[1] <= 0:
				$UI/bears/power_hint.show()
