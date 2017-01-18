extends StaticBody2D

export var team = 1

var dead = false
var hostile = false
var target = null setget _set_target

var armor = 200
var damage_taken = 0 setget _set_damage_taken

var turret_turn_rate = 12.0

func get_target_pos():
	if target != null:
		return target.get_pos()
	else:
		return Vector2()

func take_damage(source):
	if dead:return
	var dmg = source.damage
	self.damage_taken = damage_taken + dmg

func shoot():
	var turret = get_node('Turret')
	var tr = turret.get_global_transform()
	var origin = tr.o + (tr.y*32)
	var angle = turret.get_rot()+get_rot()
	var distance = get_pos().distance_to(target.get_pos())-32
	get_node('Weapon').Fire(origin,angle,distance)

func die():
	print(get_name()+" IS ESPLODE")
	dead = true

func _set_target(what):
	target = what
	if target != null:
		get_node('Turret/Lights').show()
	else:
		get_node('Turret/Lights').hide()

func _set_damage_taken(what):
	if what==damage_taken: return
	damage_taken = what
	print(damage_taken)
	if damage_taken >= armor:
		die()
	var n = 1-(1.0*damage_taken/armor)
	var fire_delay = lerp(0.1, 1.0, n)
	get_node('TriggerTime').set_wait_time(fire_delay)
	if get_node('TriggerTime').get_time_left()==0:
		get_node('TriggerTime').start()
	get_node('ArmorMeter').set_value(damage_taken)
	
func _ready():
	get_node('ArmorMeter').set_max(armor)
	get_node('ArmorMeter').set_value(damage_taken)
	set_fixed_process(true)

func _fixed_process(delta):
	if dead: set_fixed_process(false)
	if not target:
		get_node('Turret').rotate(turret_turn_rate*delta*0.1)
	else:
		var ang = get_node('Turret').get_angle_to(target.get_global_pos())
		get_node('Turret').rotate(ang*turret_turn_rate*delta)

func _on_Detector_body_enter( body ):
	if dead:return
	if 'team' in body:
		if body.team != team:
			self.target = body


func _on_Detector_body_exit( body ):
	if body == target:
		self.target = null


func _on_TriggerTime_timeout():
	if not dead:
		if target:
			shoot()
		else:
			get_node('TriggerTime').stop()
