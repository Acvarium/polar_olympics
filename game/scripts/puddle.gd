extends Area2D
export var puddle_damp = 3 

func _ready():
	pass

func _on_puddle_body_enter( body ):
	if body.is_in_group("peng"):
		body.set_damp(puddle_damp)
		print(body.get_name())

func _on_puddle_body_exit( body ):
	if body.is_in_group("peng"):
		body.reset_damp()

