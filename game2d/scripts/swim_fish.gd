extends Sprite
var speed = 120
var panic = false
var default_anim_speed = 1
var main_node
var min_pos = Vector2()
var max_pos = Vector2()

func _ready():
	main_node = get_node("/root/main")
	min_pos = main_node.min_pos
	max_pos = main_node.max_pos
	set_panic(false)

func _process(delta):
	var r = rotation
	var ss = speed 
	if panic:
		ss = speed * 4
	var velocity = Vector2(sin(r),-cos(r)).normalized() * ss * delta
	position += velocity
	
	if position.y > max_pos.y:
		position.y = min_pos.y
		set_panic(false)
	elif position.y < min_pos.y:
		position.y = max_pos.y
		set_panic(false)
	if position.x > max_pos.x:
		position.x = min_pos.x
		set_panic(false)
	elif position.x < min_pos.x:
		position.x = max_pos.x
		set_panic(false)

func set_panic(p):
	panic = p
	if panic:
		$fish_anim.playback_speed = default_anim_speed * 6
	else:
		$fish_anim.playback_speed = default_anim_speed 
		
func _on_area_body_entered( body ):
	if body.is_in_group("peng"):
		if !body.sleeping:
			set_panic(true)
