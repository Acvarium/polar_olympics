tool
extends Area2D
var pengs = []
var main_node
const in_vec = Vector2(1,0)
var l_in = Vector2(1,0)
var r_in = Vector2(-1,0)

export var vel = 1000

export var is_turntable = false setget turntable
var is_right_in = false

func _ready():
	main_node = get_node("/root/main")
	l_in = in_vec.rotated(get_rot())
	r_in = in_vec.rotated(get_rot() + PI)

	if has_node("turntable") and is_turntable:
		get_node("turntable").show()
	if !is_turntable:
		if has_node("rot"):
			get_node("rot").hide()

func turntable(new_val):
	is_turntable = new_val
	if has_node("turntable"):
		if is_turntable:
			get_node("turntable").show()
		else:
			get_node("turntable").hide()

func _fixed_process(delta):
	if pengs.size() == 0:
		set_fixed_process(false)
	else:
		for p in pengs:
			var peng = get_node(p)
			var p_vel_len = peng.get_linear_velocity().length()
			var velocity = l_in * vel
			if is_right_in:
					velocity = r_in * vel
			peng.set_linear_velocity(velocity)
				
func _on_rot_pressed():
	if is_turntable:
		var rot = get_rot()
		set_rot(rot - PI/2)
	l_in = in_vec.rotated(get_rot())
	r_in = in_vec.rotated(get_rot() + PI)


func _on_force_body_enter( body ):
	if body.is_in_group('peng'):
		if pengs.find(body.get_path()) == -1:
			pengs.append(body.get_path())
			set_fixed_process(true)
			body.norm_rot_off()
			is_right_in = l_in.dot(body.get_linear_velocity()) < 0
				
func _on_force_body_exit( body ):
	if body.is_in_group('peng'):
		if pengs.find(body.get_path()) != -1:
			pengs.remove(pengs.find(body.get_path()))
			body.norm_rot_on()