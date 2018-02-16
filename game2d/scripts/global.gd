extends Node
var original_screen_size = Vector2(1920,1080)
var current_scene = null
var max_throw = 6

const team_color = [
	Color(1,1,1,1),
	Color(1,0.5,0,1),
	Color(1,0.5,0.8,1),
	Color(0,0.7,0,1),
]

const animals = [
	'POLAR',
	'BROWM',
	'PANDA',
	'WALRUS',
	'ELK'

]
var player_name = ['POLAR','BROWM','PANDA','WALRUS']
var score = [0]

var selected_players = [1,2,0,0]

func _ready():
	set_commands(2)
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )


func start_game():
	score = []
	for i in range(selected_players.size()):
		if selected_players[i] > 0:
			score.append(0)
	goto_scene("res://scenes/main.tscn")

func goto_scene(path):
	call_deferred("_deferred_goto_scene",path)

func _deferred_goto_scene(path):
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene( current_scene )

func set_commands(c):
	global.score = []
	for i in range(c):
		global.score.append(0)