tool
extends Area2D
var _force = 6
var pengs = []
export var impuls = 1000
export var has_force = false
export var mode = 0
var canvas
var main_node
var white = Color(1,1,1,1)
var green = Color(0,1,0,1)
var blue = Color(0,0,1,1)
var red = Color(1,0,0,1)
var i_speed = 0
export var is_turntable = false setget turntable
export var is_movable = false setget movable
var right_in = ""
var is_right_in = false
var start_angle = 0

func _ready():
	main_node = get_node("/root/main")
	canvas = main_node.get_node("draw")
	if has_node("force_icon") and has_force:
		get_node("force_icon").show()
	if has_node("turntable") and is_turntable:
		get_node("turntable").show()
	if has_node("movable") and is_movable:
		get_node("movable").show()

func turntable(new_val):
	is_turntable = new_val
	if has_node("turntable"):
		if is_turntable:
			get_node("turntable").show()
		else:
			get_node("turntable").hide()

func movable(new_val):
	is_movable = new_val
	if has_node("movable"):
		if is_movable:
			get_node("movable").show()
		else:
			get_node("movable").hide()

func _fixed_process(delta):

	if pengs.size() == 0:
		set_fixed_process(false)
		return
	for p in pengs:
		if has_node(p):
			var rotated_impuls = Vector2()
			if mode == 0:
				rotated_impuls = Vector2(impuls * delta,0).rotated(get_rot())
				if is_right_in:
					rotated_impuls *= -1

				get_node(p).apply_impulse(Vector2(),rotated_impuls)
			elif mode == 1:
				rotated_impuls = (get_node("dot").get_global_pos() - get_node(p).get_global_pos())
				var p_rot = get_node(p).get_rot()
#				get_node(p).set_angular_velocity(rotated_impuls.rotated(PI/2).angle() - p_rot)
				rotated_impuls = rotated_impuls.rotated(PI/2).normalized() * impuls * delta
				get_node(p).apply_impulse(Vector2(10,0),rotated_impuls)
			elif mode == 2:
				if get_node(p).get_linear_velocity().length() > 2:
					rotated_impuls = (get_node("dot").get_global_pos() - get_node(p).get_global_pos())
					rotated_impuls = rotated_impuls.normalized() * impuls * delta
					get_node(p).apply_impulse(Vector2(10,0),rotated_impuls)
			elif mode == 3:
				i_speed = get_node(p).get_linear_velocity().length()
				rotated_impuls = (get_node("dot").get_global_pos() - get_node(p).get_global_pos())
#				var an = rotated_impuls.angle() - PI/2
				if is_right_in:
					rotated_impuls = get_node(p).get_global_pos() - get_node("dot").get_global_pos()
#					an = rotated_impuls.angle() + PI
				rotated_impuls = rotated_impuls.rotated(PI/2).normalized() * i_speed 
				
				var v = get_node(p).get_linear_velocity()
#				get_node(p).set_angular_velocity((get_node(p).get_rot() - an))
				
				rotated_impuls = rotated_impuls - v
				get_node(p).apply_impulse(Vector2(10,0), rotated_impuls )
#				get_node(p).set_linear_velocity(rotated_impuls )

			elif mode == 4:
				pass
				
func _on_force_body_enter( body ):
	if body.is_in_group('peng'):
		if mode == 0 or mode == 3:
		
			body.rot_to_velocity = true
		start_angle = int(body.get_rot() / PI/4) * PI/2
		pengs.append(body.get_path())
		i_speed = body.get_linear_velocity().length() * 60
		set_fixed_process(true)
		if body.get_path() == right_in:
			is_right_in = true

		
func _on_force_body_exit( body ):
	if pengs.find(body.get_path()) != -1:
		body.rot_to_velocity = false
		if has_node("ang"):
			get_node("ang").set_text(str(int(body.get_rotd())))
		if mode == 3:
			var v = body.get_linear_velocity()
			var vl = body.get_linear_velocity().length()
			var vec = Vector2(vl,0).rotated(get_rot()-PI/2)
			
			if is_right_in:
				vec = Vector2(vl,0).rotated(get_rot()-PI)
#		
			body.set_linear_velocity(vec )
#			body.

		
		is_right_in = false
		pengs.remove(pengs.find(body.get_path()))
		
func _on_rot_pressed():
	if is_turntable:
		var rot = get_rot()
		set_rot(rot - PI/2)

func _on_right_body_enter( body ):
	if body.is_in_group("peng"):
		print(pengs.find(body.get_path()))
		if pengs.find(body.get_path()) == -1:
			right_in = body.get_path()

func _on_right_body_exit( body ):
	if body.is_in_group("peng"):
		right_in = ''

