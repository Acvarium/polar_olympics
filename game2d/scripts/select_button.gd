extends NinePatchRect
export var stand = 0
export var avatar = 0
var player_name = ''
var global
var mouse_ower = false
var max_avatar = 5

func _ready():
	global = get_node("/root/global")
	update_avatar()

func update_avatar():
	if (stand == 0 or stand == 1):
		if avatar > max_avatar:
			avatar = 1
		elif avatar < 1:
			avatar = max_avatar
	else:
		if avatar > max_avatar:
			avatar = 0
		elif avatar < 0:
			avatar = max_avatar
	$faces.frame = avatar
	$name_pos/name.text = global.animals[avatar-1]
	if avatar == 0:
		$name_pos/name.text = ''
	global.selected_players[stand] = avatar
	global.player_name[stand] = global.animals[avatar-1]
	
func _input(event):
	if mouse_ower:
		if Input.is_action_just_pressed("w_down"):
			avatar -= 1
			update_avatar()
		if Input.is_action_just_pressed("w_up"):
			avatar += 1
			update_avatar()
func _on_Button_pressed():
	pass

func _on_Button_mouse_entered():
	mouse_ower = true

func _on_Button_mouse_exited():
	mouse_ower = false
