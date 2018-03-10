extends Patch9Frame
export var level = 0
var lock = -1
var global
export var is_set = false
var set_num = 0
var main_node
export var is_inaccessible = false

func set_lock(l):
	lock = l
	if lock < 0:
		get_node("stars").hide()
		get_node("lock").show()
	else:
		get_node("lock").hide()
		get_node("stars").show()
		for i in range(3):
			get_node("stars/star" + str(i)).set_star(int(lock >= i+1))

func set_set(s):
	is_set = true
	set_num = s
	
	get_node("stars").hide()
	get_node("Label").set_text(tr("SET") + str(s + 1))
	lock = global.worlds_locks[s]
	if lock < 0:
		get_node("lock").show()
	else:
		get_node("lock").hide()

func _ready():
	main_node = get_node("/root/main")
	global = get_node("/root/global")
	if !is_set:
		get_node("Label").set_text(str("%02d" % (level + 1)))
		set_lock(global.stages_locks[level])
	else:
		get_node("stars").hide()
	if is_inaccessible:
		set_modulate(Color(0.21,0.21,0.21))
		set_opacity(0.25)
		get_node("lock").show()

func set_level(l):
	level = l
	lock = global.stages_locks[level]
	get_node("Label").set_text(str("%02d" % (level + 1)))
	set_lock(lock)
	if global.debug_mode:
		get_node("lvl").set_tooltip(global.levels[l % global.levels.size()])


func _on_lvl_pressed():
	if is_inaccessible:
		return
	if lock > -1:
		if !is_set:
			global.level_num = level
			global.select_next_level(0)
			global.single = true
			main_node.load_single()
		else:
			main_node.show_levels_set(set_num * 16)
		