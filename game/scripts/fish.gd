extends Spatial
var speed = 1
var panic = false

func _ready():
	pass

func set_speed(s):
	$AnimationPlayer.playback_speed = s * 1.2
	speed = s
func _set_scale(s):
	scale = Vector3(s,s,s)
	
func _process(delta):
	var r = rotation.y
	var ss = speed 
	if panic:
		ss = speed * 30
	var velocity = Vector3(-sin(r), 0,-cos(r)).normalized() * ss
	translation.z += velocity.z * delta
	translation.x += velocity.x * delta
	if translation.z > 30:
		translation.z = -30
		reset_speed()
	elif translation.z < -30:
		translation.z = 30
		reset_speed()
	if translation.x > 150:
		translation.x = -30
		reset_speed()
	elif translation.x < -30:
		translation.x = 150
		reset_speed()
	

func _on_Area_body_entered( body ):
	if body.is_in_group("peng"):
		panic = true
		$AnimationPlayer.playback_speed = speed * 30
		print("aaaaa")

func reset_speed():
	panic = false
	$AnimationPlayer.playback_speed = speed * 3

