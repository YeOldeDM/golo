extends Node

export(String, MULTILINE) var name = "Autocannon"

export var fire_delay = 0 setget _set_fire_delay
export(bool) var autofire = false
export(String,FILE,'*.tscn') var bullet = null

var can_fire = true

func Fire():
	if can_fire:
		var turret = get_node('../Turret')
		var tr = turret.get_global_transform()
		var origin = tr.o + (tr.y*48)
		var angle = turret.get_rot() + get_parent().get_rot()
		var distance = get_parent().get_pos().distance_to(get_parent().get_target_pos())
		distance = max(64,distance)
		var b = load(bullet).instance()
		get_node('../../').add_child(b)
		b.Fire(get_parent(),origin,angle,distance)
		if fire_delay > 0:
			can_fire = false
			get_node('Timer').start()

func _set_fire_delay(what):
	fire_delay = what
	if has_node('Timer'):
		get_node('Timer').set_wait_time(fire_delay)

func _enter_tree():
	get_node('Timer').connect('timeout',self,'_on_fire_delay_timeout')
	if fire_delay > 0:
		get_node('Timer').set_wait_time(fire_delay)

func _ready():
	pass


func _on_fire_delay_timeout():
	if !can_fire:
		can_fire = true