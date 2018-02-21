extends Node
var original_screen_size = Vector2(1920,1080)
var current_scene = null
var max_throw = 6
var game_cersion = '0.3.0'
var go_to_next = 0

const team_color = [
	Color(1,1,1,1),
	Color(1,0.53,0,1),
	Color(1,0.4,0.9,1),
	Color(0.0,0.84,0.0,1),
]

const animals = [
	'POLAR',			#00
	'BROWM',			#01
	'PANDA',			#02
	'WALRUS',			#03
	'ELK',				#04
	'',					#05
	'',					#06
	'',					#07
	'',					#08
	'',					#09
	'',					#10
	'',					#11
	'',					#12
	'',					#13
	'',					#14
	'',					#15
	'',					#16
	'',					#17
	'',					#18
	'',					#19
	'',					#20
	'',					#21
	'COMPY',					#22
]

var player_name = ['POLAR','BROWM','PANDA','WALRUS']
var score = [0]

var selected_players = [1,2,3,4]

func _ready():
	set_commands(2)
#	get_tree().set_auto_accept_quit(true)
#	get_tree().set_quit_on_go_back(false)
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )
	var r = get_tree().get_root().get_rect()
	r.size = Vector2(1920,1080)
	
func start_game():
	score = []
	for i in range(selected_players.size()):
		if selected_players[i] > 0:
			score.append(0)
	if score.size() == 4:
		max_throw = 5
	goto_scene("res://scenes/main.tscn")

func goto_scene(path):
	if  go_to_next <= 1:
		call_deferred("_deferred_goto_scene",path)

func _deferred_goto_scene(path):
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene( current_scene )
	go_to_next += 1

func set_commands(c):
	global.score = []
	for i in range(c):
		global.score.append(0)