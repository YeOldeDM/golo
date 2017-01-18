extends KinematicBody2D
var owned_by
var aim_range
var start_pos

export var speed = 1000
export(float) var damage = 1

func Fire(owner, origin, angle, distance):
	owned_by = owner
	aim_range = distance
	start_pos = origin
	set_pos(origin)
	set_rot(angle)
	set_fixed_process(true)

func kill():
	var puff = preload('res://SmokePuff.tscn').instance()
	get_parent().add_child(puff)
	puff.set_pos(get_pos())
	puff.set_rot(get_rot())
	queue_free()

func _fixed_process(delta):
	move(get_transform().y*delta*speed)
	if get_pos().distance_to(start_pos) >= aim_range:
		kill()
#	var s = get_node('Sprite').get_scale()
#	s.y += speed*delta*0.01
#	get_node('Sprite').set_scale(s)

func _on_HitBox_body_enter( body ):
	if body != owned_by:
		if body.has_method('take_damage'):
			body.take_damage(self)
		kill()
