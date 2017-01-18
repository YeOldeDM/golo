extends Position2D

func activate(lgm=null):
	get_node('Camera').make_current()
	if lgm:
		set_pos(lgm.get_pos())
		lgm.call_deferred('kill')
	
	get_parent().get_node('HUD/GameOver').show()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
