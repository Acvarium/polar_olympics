extends Node
var original_screen_size = Vector2(1920,1080)
const team_color = [
	Color(1,1,1,1),
	Color(1,0.5,0,1),
]
var score = [0]

func _ready():
	set_commands(2)

func set_commands(c):
	global.score = []
	for i in range(c):
		global.score.append(0)