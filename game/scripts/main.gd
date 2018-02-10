extends Node
var pointer
var pDirection = 0
var rDir = 1
var pSpeed = 2
var dMinMax = 1
var penguin_obj = load("res://objects/penguin.tscn")
var testP
var fish_obj = load("res://models/fish.tscn")

func _ready():
	randomize()
	testP = $penguin2
	pointer = $Spatial/pointer
	$fishes/fish/AnimationPlayer.get_animation("fish").set_loop(true)
	for i in range(30):
		var fish = fish_obj.instance()
		fish.set_speed(randf() * 0.5 + 0.5)
		fish._set_scale(randf() * 0.2 + 1)
		fish.translation = Vector3(randf() * 180 - 30, 0, randf() * 60 - 30)
		fish.rotation = Vector3(0,randf() * PI*2, 0)
		$fishes.add_child(fish)
	
func _input(event):
	if Input.is_action_just_pressed("fire"):
		var penguin = penguin_obj.instance()
		var r = pointer.rotation.y - PI/2
		penguin.rotation.y = r
#		print(pointer.rotation)
		penguin.linear_velocity = Vector3(-sin(r), 0,-cos(r)).normalized() * (randf() * 60 + 10)
		$pengs.add_child(penguin)

	
func _physics_process(delta):
	var on_screen_pos = $Camera.unproject_position($penguin.translation)
#	print(on_screen_pos)
	$UI/pos.position = on_screen_pos
	$UI/pos/Label.text = str(on_screen_pos)
	pDirection += pSpeed * rDir * delta
	
	if rDir == 1:
		if pDirection > dMinMax:
			rDir = -1
	else:
		if pDirection < -dMinMax:
			rDir = 1
#	print(pDirection)
	pointer.rotation.y = pDirection