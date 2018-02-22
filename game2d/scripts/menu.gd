extends Node2D
var screen_size
var screen_scale
var global
var tab_num = 4
var selected_tab = 0
var selected_stand = 0

var labels = [
'SINGLE',
'HOTSEAT',
'LAN',
'ONLINE']

func _ready():
	global = get_node("/root/global")
	resizer()
	get_tree().get_root().connect("size_changed", self, "resizer")
	select_tab(1)

func resizer():
	screen_size = get_tree().root.get_visible_rect().size
	print(screen_size)
	var ratio = screen_size.x/screen_size.y
	screen_scale = Vector2(global.original_screen_size.x / screen_size.x, global.original_screen_size.y / screen_size.y)
	var horizontal = ratio * global.original_screen_size.y 
	var vertoical = global.original_screen_size.x / ratio
	$Camera.zoom = Vector2(screen_scale.y, screen_scale.y)
	var control_scale = ratio / (global.original_screen_size.x/global.original_screen_size.y)
	$Control.rect_scale = Vector2(control_scale,control_scale)
#	$hint.rect_scale = Vector2(control_scale,control_scale)
	$Control/rect.margin_bottom = vertoical

func select_tab(t):
	get_node("Control/tabs/tab" + str(selected_tab)).show()
	get_node("Control/tabs/tab" + str(t)).hide()
	selected_tab = t
	var s_pos = get_node("Control/tabs/selected_pos/p" + str(t)).position
	$Control/tabs/selected_tab.position = s_pos
	$Control/tabs/selected_tab/label.text = labels[t]
	$Control/tabs/label.text = labels[t]
	$Control/tabs/selected_tab/not_available_icon.visible = !(t == 1)
	for i in range(tab_num):
		get_node("Control/mode" + str(i)).visible = (t == i)
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST or what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit() 

func _input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
func set_selected_stand(s):
	selected_stand = s
	$Control/char_selector.show()
	$Control/char_selector/x_button.visible = (s > 1)

func set_face(f):
	var select_button = get_node("Control/mode1/select_button" + str(selected_stand))
	select_button.avatar = f
	select_button.update_avatar()
	$Control/char_selector.hide()

#	var ratio = screen_size.x/screen_size.y
#	screen_scale = Vector2(global.original_screen_size.x / screen_size.x, global.original_screen_size.y / screen_size.y)
#	var horizontal = ratio * global.original_screen_size.y 
#	$camera_position/Camera.zoom = Vector2(screen_scale.y, screen_scale.y)
#	$camera_position/Camera/data_ui.margin_right = horizontal


func _on_Button_pressed():
	global.start_game()

func _on_Button0_pressed():
	select_tab(0)

func _on_Button1_pressed():
	select_tab(1)

func _on_Button2_pressed():
	select_tab(2)

func _on_Button3_pressed():
	select_tab(3)

func _on_x_button_pressed():
	set_face(0)

func _on_cancel_pressed():
	$Control/char_selector.hide()

func _on_quit_button_pressed():
	get_tree().quit()
