extends StaticBody2D
var rays = []
var pressed = false
var step = 228
var pengs = []

func _ready():
	rays.append(get_node("ray_up"))
	rays.append(get_node("ray_right"))
	rays.append(get_node("ray_down"))
	rays.append(get_node("ray_left"))
	for r in rays:
		r.add_exception(self)

func _process(delta):
	if pressed:
		for r in rays:
			r.force_raycast_update()
		var pos_dif = get_global_mouse_pos() - get_global_pos()
		#up
		if pos_dif.y < -(step / 2) and !rays[0].is_colliding():
			move(Vector2(0,-1))
		#right
		elif pos_dif.x > (step / 2) and !rays[1].is_colliding():
			move(Vector2(1,0))
		#down
		elif pos_dif.y > (step / 2) and !rays[2].is_colliding():
			move(Vector2(0,1))
		#left
		elif pos_dif.x < -(step / 2) and !rays[3].is_colliding():
			move(Vector2(-1,0))
func move(dir):
	var pos = get_pos()
	pos += dir * step
	set_pos(pos)

func _on_Button_button_down():
	if pengs.size() == 0:
		set_process(true)
		pressed = true
		get_node("dot").show()
	
func _on_Button_button_up():
	set_process(false)
	get_node("dot").hide()
	pressed = false

func _on_penget_body_enter( body ):
	if body.is_in_group("peng"):
		get_node("dot1").show()
		if pengs.find(body.get_path()) == -1:
			pengs.append(body.get_path())

func _on_penget_body_exit( body ):
	if body.is_in_group("peng"):
		if pengs.find(body.get_path()) != -1:
			pengs.remove(pengs.find(body.get_path()))
		if pengs.size() == 0:
			get_node("dot1").hide()
