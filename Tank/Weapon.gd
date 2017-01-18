extends Node

export(String, MULTILINE) var name = "Autocannon"

export(float) var fire_delay = 0.0 setget _set_fire_delay
export(bool) var autofire = false
export(String,FILE,'*.tscn') var bullet = null

var can_fire = true

func Fire(origin,angle,distance):
	if can_fire:
		var b = load(bullet).instance()
		get_node('../../').add_child(b)
		b.Fire(get_parent(),origin,angle,distance)
		if fire_delay > 0:
			can_fire = false
			get_node('Timer').start()
		if get_parent().has_node('SfxGuns'):
			get_node('../SfxGuns').play('ac_fire_heavy')

func _set_fire_delay(what):
	fire_delay = what
	if has_node('Timer'):
		get_node('Timer').set_wait_time(fire_delay)


func _ready():
	get_node('Timer').connect('timeout',self,'_on_fire_delay_timeout')
	if fire_delay > 0:
		get_node('Timer').set_wait_time(fire_delay)


func _on_fire_delay_timeout():
	if !can_fire:
		can_fire = true