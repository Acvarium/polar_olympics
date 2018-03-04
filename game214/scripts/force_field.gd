extends Area2D
var _force = 6
var pengs = []
export var impuls = 1000
export var vis = false
export var mode = 0
var canvas
var main_node
var white = Color(1,1,1,1)
var green = Color(0,1,0,1)
var blue = Color(0,0,1,1)
var red = Color(1,0,0,1)
var i_speed = 0


func _ready():
	main_node = get_node("/root/main")
	canvas = main_node.get_node("draw")
	if has_node("force_icon"):
		if vis:
			get_node("force_icon").show()
		else:
			get_node("force_icon").hide()

func _fixed_process(delta):
	if pengs.size() == 0:
		set_fixed_process(false)
		return
	for p in pengs:
		if has_node(p):
			var rotated_impuls = Vector2()
			if mode == 0:
				rotated_impuls = Vector2(impuls * delta,0).rotated(get_rot())
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
				canvas.lines = []
				rotated_impuls = (get_node("dot").get_global_pos() - get_node(p).get_global_pos())
				var a = get_node(p).get_global_pos()
				canvas.lines.append([get_node("dot").get_global_pos(), a, white])
				var p_rot = get_node(p).get_rot()
				rotated_impuls = rotated_impuls.rotated(PI/2).normalized() * i_speed * delta
				
				canvas.lines.append([a, a + rotated_impuls * 10, green])
				var an = rotated_impuls.angle() - PI/2
#				get_node(p).set_rot(rotated_impuls.angle() - PI/2)
				var v = get_node(p).get_linear_velocity()
#				get_node(p).set_angular_velocity((get_node(p).get_rot() - an) * v.length()*0.012)
				get_node(p).set_angular_velocity((get_node(p).get_rot() - an))
				
				canvas.lines.append([a, a + v , blue])
				
				var b = rotated_impuls - v
				rotated_impuls = b
				
				canvas.lines.append([a, a + b * 100, red])
				get_node(p).apply_impulse(Vector2(10,0), rotated_impuls )
#				canvas.update()
			
func _on_force_body_enter( body ):
	if body.is_in_group('peng'):
		pengs.append(body.get_path())
		i_speed = body.get_linear_velocity().length() * 60
		set_fixed_process(true)

		
func _on_force_body_exit( body ):
	if pengs.find(body.get_path()) != -1:
		if mode == 3:
			var v = body.get_linear_velocity()
			var vl = body.get_linear_velocity().length()
			var vec = Vector2(vl,0).rotated(get_rot()-PI/2)
			var a = v.angle()
			body.set_linear_velocity(vec )
#			body.set_rot(get_rot()-PI/2)
#			body.set_angular_velocity(0)
#			body.set_angular_velocity(body.get_rot() - (get_rot()-PI/2))
		
#		body.set_angular_velocity(((get_rot()-PI/2) - a))
		
		pengs.remove(pengs.find(body.get_path()))
		
func _on_rot_pressed():
	var rot = get_rot()
	set_rot(rot - PI/2)
