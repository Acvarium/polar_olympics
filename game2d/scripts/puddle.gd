extends Area2D
export var puddle_damp = 3 

func _ready():
	pass


func _on_puddle_body_entered( body ):
	if body.is_in_group("peng"):
		body.set_damp(puddle_damp)


func _on_puddle_body_exited( body ):
	if body.is_in_group("peng"):
		body.reset_damp()
