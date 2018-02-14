extends Area2D
var main_node

func _ready():
	main_node = get_node("/root/main")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_fish_body_entered( body ):
	if body.is_in_group("peng"):
		main_node.bonus(body.team, 1, 'fish')
		queue_free()
