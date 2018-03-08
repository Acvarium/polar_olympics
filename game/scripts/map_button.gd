extends Patch9Frame
export var map = -1
var selected = false
var global
var main_node


func _ready():
	global = get_node("/root/global")
	main_node = get_node("/root/main")
	if map == -1:
		get_node("Label").set_text("DEFAULT")
	else:
		get_node("Label").set_text("MAP " + str(map + 1))
	
	var map_img = "res://textures/maps/map_" + str(map+1) + ".png"
	var texture = load(map_img) 
	get_node("map_0").set_texture(texture)
	
		
func update_selections():
	if global.selected_map == map:
		get_node("is_selected").show()
	else:
		get_node("is_selected").hide()
		

func _on_map_button_pressed():
	global.select_map(map)
	main_node.update_map_button()
	main_node.hide_map_selector()
	
