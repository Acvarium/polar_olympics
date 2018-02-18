extends Node2D
var screen_size
var screen_scale
var global
var tab_num = 4
var selected_tab = 0

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
	var ratio = screen_size.x/screen_size.y
	screen_scale = Vector2(global.original_screen_size.x / screen_size.x, global.original_screen_size.y / screen_size.y)
	var horizontal = ratio * global.original_screen_size.y 
	$Camera.zoom = Vector2(screen_scale.y, screen_scale.y)

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
