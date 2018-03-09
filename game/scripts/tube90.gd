tool
extends Area2D
var pengs = []
var main_node
const in_vec = Vector2(1,0)
var l_in = Vector2(1,0)
var r_in = Vector2(0,-1)
var l_out = l_in.rotated(PI)
var r_out = r_in.rotated(PI)
export var vel = 1000

export var is_turntable = false setget turntable
var is_right_in = false

func _ready():
	main_node = get_node("/root/main")
	l_in = in_vec.rotated(get_rot())
	r_in = in_vec.rotated(get_rot() + PI/2)
	l_out = l_in.rotated(PI)
	r_out = r_in.rotated(PI)
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
	if pengs.size() > 0:
		if is_right_in:
			get_node("right_arrow").show()
			get_node("left_arrow").hide()
		else:
			get_node("right_arrow").hide()
			get_node("left_arrow").show()
		for p in pengs:
			var peng = get_node(p)
			var p_vel_len = peng.get_linear_velocity().length()
			var velocity = (get_node("dot").get_global_pos() - peng.get_global_pos())
			if is_right_in:
					velocity = peng.get_global_pos() - get_node("dot").get_global_pos()
			velocity = velocity.rotated(PI/2).normalized() * vel  
			var out_vec = r_out
			if is_right_in:
				out_vec = l_out
			peng.set_linear_velocity(velocity)
			if abs(velocity.normalized().dot(out_vec)) > 0.99:
				peng.norm_rot_on()
				
				pengs.remove(pengs.find(p))
				peng.set_linear_velocity(out_vec * vel)
	else:
		get_node("right_arrow").hide()
		get_node("left_arrow").hide()
		set_fixed_process(false)
				
func _on_rot_pressed():
	if is_turntable:
		var rot = get_rot()
		set_rot(rot - PI/2)
	l_in = in_vec.rotated(get_rot())
	r_in = in_vec.rotated(get_rot() + PI/2)
	l_out = l_in.rotated(PI)
	r_out = r_in.rotated(PI)

func _on_force_body_enter( body ):
	if body.is_in_group('peng'):
		if pengs.find(body.get_path()) == -1:
			pengs.append(body.get_path())
			set_fixed_process(true)
			is_right_in = false
			body.norm_rot_off()

func _on_right_body_enter( body ):
	if body.is_in_group('peng'):
		if pengs.find(body.get_path()) == -1:
			pengs.append(body.get_path())
			set_fixed_process(true)
			is_right_in = true
			body.norm_rot_off()

