extends Position2D
var pOwner


func _ready():
	pass

func update_score(s):
	$Label.text = str(s)
	if s == 0:
		hide()
	else:
		show()