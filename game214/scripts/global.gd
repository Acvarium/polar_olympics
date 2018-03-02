extends Node

const MAX_STAGE = 200
const MAX_WORLD = 20

var stage = 1
var stages_locks = []
var worlds_locks = []

var original_screen_size = Vector2(1920,1080)
var current_scene = null
var max_throw = 6
var game_version = '0.5.2'
var single = false
var current_level = "res://levels/level0.tscn"
var next_level = "res://levels/level0.tscn"
var selected_tab = 1
var level_num = 0
var no_save = false
var team = 0
var control_type = 1
var volume_scale = 1
var tutorial = 1

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
	'BROWN',			#01
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
var player_name = ['POLAR','BROWN','PANDA','WALRUS']
var score = [0]
var selected_players = [1,23,0,0]

func _ready():

	set_commands(1)
	get_tree().set_auto_accept_quit(false)
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )
	load_game()
	if no_save:
		save_game()
	
func start_game():
	team = 0
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
	savegame.store_line({'version':game_version}.to_json())
	savegame.store_line({'control_type':str(control_type)}.to_json())
	savegame.store_line({'volume_scale':str(volume_scale)}.to_json())
	savegame.store_line({'tutorial':str(tutorial)}.to_json())
	
	for i in range(worlds_locks.size()):
		savegame.store_line({'world_' + str(i):worlds_locks[i]}.to_json())
	for i in range(stages_locks.size()):
		savegame.store_line({'stage_' + str(i):stages_locks[i]}.to_json())
	savegame.close()

func set_volume(v):
	volume_scale = v
	AudioServer.set_stream_global_volume_scale(volume_scale)

func toggle_mute():
	volume_scale = int(!bool(volume_scale))
	set_volume(volume_scale)

# Завантаження гри
func load_game():
	var savegame = File.new()
	if !savegame.file_exists(save_file):
		stages_locks.clear()
		worlds_locks.clear()
		for i in range(MAX_WORLD):
			worlds_locks.append(1)
		for i in range(MAX_STAGE):
			stages_locks.append(1)
		worlds_locks[0] = 0
		stages_locks[0] = 0
		no_save = true
		return #Error!  We don't have a save to load
	var currentline = {} 
	savegame.open(save_file, File.READ)
	stages_locks.clear()
	var n = 0
	while (!savegame.eof_reached()):
		n += 1
		currentline.parse_json(savegame.get_line())
	for i in range(MAX_STAGE):
		stages_locks.append(currentline['stage_' + str(i)])
	savegame.close()
	control_type = (int(currentline['control_type']))
	if currentline.has('tutorial'):
		tutorial = int(currentline['tutorial'])
	set_volume(int(currentline['volume_scale']))

func game_quit():
	save_game()
	get_tree().quit()
	
	

