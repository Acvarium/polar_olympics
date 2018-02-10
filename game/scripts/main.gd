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
var state = 0
var target
var target_radius = 12.5
var max_power = 90
var min_power = 5
var power = 0
var current_penguin

func _ready():
	randomize()
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
	$power_cube.hide()
	$Spatial/pointer.hide()
	var penguin = penguin_obj.instance()
	var r = pointer.rotation.y - PI/2
	penguin.rotation.y = r
#		print(pointer.rotation)
	penguin.linear_velocity = Vector3(-sin(r), 0,-cos(r)).normalized() * power
	$pengs.add_child(penguin)

	var score_cloud = score_cloud_obj.instance()
	score_cloud.pOwner = penguin
	$UI/counters.add_child(score_cloud)
	score_cloud.position = $Camera.unproject_position(score_cloud.pOwner.translation)
	$camera_anim.play("fire")

func _input(event):
	if Input.is_action_just_pressed("fire"):
		state += 1
		if state > 1:
			fire()
			state = 0
		elif state == 1:
#			$power_cube.hide()
			$Spatial/pointer.show()
	
func _physics_process(delta):
	if state == 0:
		power += power_speed * rDir * delta
		if power > max_power:
			rDir = -1
		if power < min_power:
			rDir = 1
		print(power)
		$power_cube.scale.z = power / max_power * 3
	elif state == 1:
		pDirection += pSpeed * rDir * delta
		if rDir == 1:
			if pDirection > dMinMax:
				rDir = -1
		else:
			if pDirection < -dMinMax:
				rDir = 1
		pointer.rotation.y = pDirection
		
	for score_cloud in $UI/counters.get_children():
		score_cloud.position = $Camera.unproject_position(score_cloud.pOwner.translation)
		var distance = dist_to_target(score_cloud.pOwner.translation)
		
		score_cloud.update_score(score_count(distance))

func _on_camera_anim_animation_finished( anim_name ):
	state = 0
	$power_cube.show()
	power = min_power
#	$Spatial/pointer.show()