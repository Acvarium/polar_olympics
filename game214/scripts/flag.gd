extends Position2D
var penguin

func _ready():
	pass

func set_color(c):
	get_node("sprite").set_modulate(c)