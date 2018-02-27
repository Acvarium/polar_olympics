extends Node

const MAX_STAGE = 200

var stage = 1
var stages_lock = []

var original_screen_size = Vector2(1920,1080)
var current_scene = null
var max_throw = 6
var game_version = '0.4.0'
var single = false
var current_level = "res://levels/level0.tscn"
var next_level = "res://levels/level0.tscn"
var selected_tab = 1
var level_num = 0
var no_save = false

#var save_file = 'user://po_savegame.save'
var save_file = "user://po_savegame.save"

var levels = [
"res://levels/level0.tscn",
"res://levels/level1.tscn",
"res://levels/level2.tscn",
"res://levels/level3.tscn",
"res://levels/level4.tscn",
"res://levels/level5.tscn",
]

func select_next_level(l):
	current_level = next_level
	level_num += l
	if level_num > (levels.size() - 1):
		level_num = 0
	next_level = levels[level_num]


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
	'COMPY',			#22
]
var player_name = ['POLAR','BROWM','PANDA','WALRUS']
var score = [0]
var selected_players = [1,23,3,4]

func _ready():
	set_commands(1)
	get_tree().set_auto_accept_quit(false)
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )
	load_game()
	if no_save:
		save_game()
	
	
func start_game():
	score = []
	for i in range(selected_players.size()):
		if selected_players[i] > 0:
			score.append(0)
	if score.size() == 4:
		max_throw = 5
	else:
		max_throw = 6
		
	goto_scene("res://scenes/main.tscn")

func goto_scene(path):
	call_deferred("_deferred_goto_scene",path)

func _deferred_goto_scene(path):
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene( current_scene )

func set_commands(c):
	global.score = []
	for i in range(c):
		global.score.append(0)
		

# Збереження гри
func save_game():
	var savegame = File.new()
	savegame.open(save_file, File.WRITE)
	for i in range(stages_lock.size()):
		savegame.store_line({str(i):stages_lock[i]}.to_json())
	savegame.close()

# Завантаження гри
func load_game():
	var savegame = File.new()
	if !savegame.file_exists(save_file):
		for i in range(MAX_STAGE):
			stages_lock.append(1)
		stages_lock[0] = 0
		no_save = true
		return #Error!  We don't have a save to load
	var currentline = {} 
	savegame.open(save_file, File.READ)
	stages_lock.clear()
	var n = 0
	while (!savegame.eof_reached()):
		n += 1
		currentline.parse_json(savegame.get_line())
	for i in range(MAX_STAGE):
		stages_lock.append(currentline[str(i)])
	savegame.close()

