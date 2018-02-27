extends Area2D
var _force = 6
var pengs = []
export var impuls = 1000
export var vis = false

func _ready():
	if vis:
		get_node("force_icon").show()
	else:
		get_node("force_icon").hide()

func _fixed_process(delta):
	if pengs.size() == 0:
		set_fixed_process(false)
		return
	for p in pengs:
		if has_node(p):
			var rotated_impuls = Vector2(impuls * delta,0).rotated(get_rot())
			get_node(p).apply_impulse(Vector2(),rotated_impuls)
	
func _on_force_body_enter( body ):
	if body.is_in_group('peng'):
		pengs.append(body.get_path())
		set_fixed_process(true)

		
func _on_force_body_exit( body ):
	if pengs.find(body.get_path()) != -1:
		pengs.remove(pengs.find(body.get_path()))