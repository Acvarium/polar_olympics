extends Node2D
var screen_size
var screen_scale
var global

func _ready():
	global = get_node("/root/global")
	resizer()
	get_tree().get_root().connect("size_changed", self, "resizer")

func resizer():
	screen_size = get_tree().root.get_visible_rect().size
	var ratio = screen_size.x/screen_size.y
	screen_scale = Vector2(global.original_screen_size.x / screen_size.x, global.original_screen_size.y / screen_size.y)
	var horizontal = ratio * global.original_screen_size.y 
	$Camera.zoom = Vector2(screen_scale.y, screen_scale.y)

func _on_Button_pressed():
	global.start_game()
