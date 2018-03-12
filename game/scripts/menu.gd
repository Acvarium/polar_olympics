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
	
	if OS.get_name() == "Android":
		get_node("Control/rect/hint/full_screen").hide()
	global = get_node("/root/global")
	set_process_input(true)
	get_node("Control/rect/hint/v_sliding").set_pressed(global.v_slide_allow)
	resizer()
	get_tree().get_root().connect("size_changed", self, "resizer")
	select_tab(global.selected_tab)
	update_dots()
	get_node("Control/rect/hint/version").set_text("version " + global.game_version)
	get_node("Control/tabs/mute").set_pressed(!bool(global.volume_scale))
	get_node("Control/rect/hint/tutorial").set_pressed(bool(global.tutorial))
	get_node("Control/rect/hint/full_screen").set_pressed(global.full_screen)

	for i in range(get_node("Control/mode0/sets").get_child_count()):
		
		get_node("Control/mode0/sets/lvl" + str(i)).set_set(i)
	if global.is_levels_shown:
		show_levels_set(global.set_selected)
	if global.selected_tab != 1:
		get_node("Control/rect/hint/v_sliding").hide()

func _input(event):
	if event.is_action_pressed("quit"):
		global.game_quit()
	
	if event.is_action_pressed("ui_up"):
		OS.set_window_maximized(true)
	
	if event.is_action_pressed("fire"):
		global.start_game()

func hide_map_selector():
	get_node("Control/map_selector").hide()

func update_dots():
	var d = 0
	for i in range(4):
		var b = get_node("Control/mode1/select_button" + str(i))
		if b.avatar == 0:
			b.set_team_color(Color(0,0,0,0))
		else:
			b.set_team_color(global.team_color[d])
			d += 1
			
func resizer():
	screen_size = get_tree().get_root().get_visible_rect().size
	var ratio = screen_size.x/screen_size.y
	screen_scale = Vector2(global.original_screen_size.x / screen_size.x, global.original_screen_size.y / screen_size.y)
	var horizontal = ratio * global.original_screen_size.y 
	var vertoical = global.original_screen_size.x / ratio
	get_node("Camera").set_zoom(Vector2(screen_scale.y, screen_scale.y))
	var control_scale = ratio / (global.original_screen_size.x/global.original_screen_size.y)
	get_node("Control").set_scale(Vector2(control_scale,control_scale))
	get_node("Control/rect").set_size(Vector2(screen_size.x, vertoical))

func set_face(f):
	var select_button = get_node("Control/mode1/select_button" + str(selected_stand))
	select_button.avatar = f
	select_button.update_avatar()
	get_node("Control/char_selector").hide()
	update_dots()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		global.game_quit()
#		
func set_selected_stand(s):
	selected_stand = s

	get_node("Control/char_selector").show()
	if s > 1:
		get_node("Control/char_selector/x_button").show()
	else:
		get_node("Control/char_selector/x_button").hide()

func update_map_button():
	var map_img = "res://textures/maps/map_" + str(global.selected_map+1) + ".png"
	var texture = load(map_img) 
	get_node("Control/mode1/map/map").set_texture(texture)
	
	


func select_tab(t):
	get_node("Control/tabs/tab" + str(selected_tab)).show()
	get_node("Control/tabs/tab" + str(t)).hide()
	selected_tab = t
	var s_pos = get_node("Control/tabs/selected_pos/p" + str(t)).get_pos()
	get_node("Control/tabs/selected_tab").set_pos(s_pos)
	get_node("Control/tabs/selected_tab/label").set_text(labels[t])
	get_node("Control/tabs/label").set_text(labels[t])
	if t <= 1:
		get_node("Control/tabs/selected_tab/not_available_icon").hide()
	else:
		get_node("Control/tabs/selected_tab/not_available_icon").show()
		
	for i in range(tab_num):
		if t == i:
			get_node("Control/mode" + str(i)).show()
		else:
			get_node("Control/mode" + str(i)).hide()
#	if selected_tab != 1:
#		get_node("Control/rect/hint/tap_mode").hide()
#	else:
#		get_node("Control/rect/hint/tap_mode").show()
#	
func _on_Button0_pressed():
	select_tab(0)
	global.selected_tab = 0
	get_node("Control/rect/hint/v_sliding").hide()

func _on_Button1_pressed():
	select_tab(1)
	global.selected_tab = 1
	get_node("Control/rect/hint/v_sliding").show()

func _on_Button2_pressed():
	select_tab(2)
	global.selected_tab = 2
	get_node("Control/rect/hint/v_sliding").hide()

func _on_Button3_pressed():
	select_tab(3)
	global.selected_tab = 3
	get_node("Control/rect/hint/v_sliding").hide()

func show_levels_set(n):
	global.set_selected = n
	get_node("Control/mode0/sets").hide()
	get_node("Control/mode0/levels_block").show()
	global.is_levels_shown = true
	for i in range(get_node("Control/mode0/levels_block/levels").get_child_count()):
		var l = get_node("Control/mode0/levels_block/levels/lvl" + str(i))
		l.set_level(i + n)

func _on_start_button_pressed():
	for c in get_node("Control").get_children():
		c.hide()
	get_node("Control/loading").show()
	get_node("timers/start_hotseat").start()

func load_single():
	for c in get_node("Control").get_children():
		c.hide()
	get_node("Control/loading").show()
	get_node("timers/start_single").start()
	
func _on_cancel_pressed():
	get_node("Control/char_selector").hide()
	get_node("Control/map_selector").hide()

func _on_quit_button_pressed():
	global.game_quit()

func _on_lvl0_pressed():
	global.single = true
	global.next_level = global.levels[0]
	global.goto_scene("res://scenes/main.tscn")

func _on_mute_toggled( pressed ):
	global.toggle_mute()
	get_node("Control/tabs/mute").set_pressed(!bool(global.volume_scale))

func _on_tutorial_toggled( pressed ):
	global.tutorial = int(get_node("Control/rect/hint/tutorial").is_pressed())

func _on_full_screen_toggled( pressed ):
	OS.set_window_fullscreen(pressed)
	global.full_screen = pressed

func _on_back_button_pressed():
	get_node("Control/mode0/levels_block").hide()
	get_node("Control/mode0/sets").show()
	global.is_levels_shown = false

func _on_map_button_pressed():
	get_node("Control/map_selector").show()

	for b in get_node("Control/map_selector/buttons").get_children():
		b.update_selections()

func _on_start_single_timeout():
	global.goto_scene("res://scenes/main.tscn")

func _on_start_hotseat_timeout():
	global.single = false
	global.start_game()

func _on_v_sliding_toggled( pressed ):
	global.v_slide_allow = pressed
