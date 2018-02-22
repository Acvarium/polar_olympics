extends Patch9Frame
export var stand = 0
export var avatar = 0
var player_name = ''
var global
var mouse_ower = false
var max_avatar = 5
export var in_selector = false
export var xxx = false
var main_node

func _ready():
	global = get_node("/root/global")
	main_node = get_node("/root/main")
	update_avatar()
	if !in_selector:
		get_node("dot").show()
		
	else:
		get_node("dot").hide()

func set_team_color(c):
	get_node("dot").set_modulate(c)

func update_avatar():
	if xxx:
		for o in get_children():
			o.hide()
		get_node("x").show()
		get_node("Button").show()
		return 
	else:
		for o in get_children():
			o.show()
		get_node("x").hide()
		
	if !in_selector:
		if (stand == 0 or stand == 1):
			if avatar > max_avatar  and avatar != 23:
				avatar = 1
			elif avatar < 1:
				avatar = max_avatar
		else:
			if avatar > max_avatar and avatar != 23:
				avatar = 0
			elif avatar < 0:
				avatar = max_avatar
		global.selected_players[stand] = avatar
		global.player_name[stand] = global.animals[avatar-1]
	get_node("faces").set_frame(avatar)
	get_node("name").set_text(global.animals[avatar-1])
	if avatar == 0:
		get_node("name").set_text('')


func _input(event):
	if in_selector:
		return
	if mouse_ower:
		if Input.is_action_just_pressed("w_down"):
			avatar -= 1
			update_avatar()
		if Input.is_action_just_pressed("w_up"):
			avatar += 1
			update_avatar()
			
func _on_Button_pressed():
	if xxx:
		main_node.set_face(0)
		return
	if in_selector:
		main_node.set_face(avatar)
	else:
		main_node.set_selected_stand(stand)
