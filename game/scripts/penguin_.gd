extends Spatial

func _ready():

	pass

func anim_stop():
	$AnimationPlayer.stop(true)

func anim_play():
	$AnimationPlayer.play("slide")