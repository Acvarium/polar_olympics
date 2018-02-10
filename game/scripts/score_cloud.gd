extends Position2D
var pOwner
const teamColors = [
Color(1,1,1,1),
Color(1,0.5,0,1),
]
var team = 0

func set_team(t):
	team = t
	$icon.modulate = teamColors[t]
	$dot.modulate = teamColors[t]
		

func _ready():
	set_team(1)

func update_score(s):
	$Label.text = str(s)
	if s == 0:
		$icon.hide()
		$Label.hide()
	else:
		$icon.show()
		$Label.show()