extends KinematicBody2D



signal top_speed_changed(what)
var top_speed = 70 setget _set_top_speed

signal groundID_changed(what)
var groundID = -1 setget _set_groundID

signal facing_changed(what)
var facing = 0 setget _set_facing


var armor = 5
var damage_taken = 0 setget _set_damage_taken


var is_using = false

var team = 0

func activate(tank=null):
	get_node('Camera').make_current()
	if tank:
		tank.call_deferred('deactivate')

func deactivate():
	queue_free()

func shoot():
	var aimer = get_node('../Aimer')
	var tr = get_global_transform()
	var origin = tr.o + ((aimer.get_pos()-get_pos()).normalized()*16)
	var angle = get_angle_to(aimer.get_pos())
	var distance = get_pos().distance_to(aimer.get_pos())
	print(distance)
	get_node('Weapon').Fire(origin,angle,distance)

func take_damage(source):
	var dmg = source.damage
	self.damage_taken = damage_taken+dmg
	
	var v = source.get_global_transform().y*source.damage
	move(v)


func die():
	get_parent().get_node('Spectator').call_deferred('activate',self)

func kill():
	var corpse = preload('res://LGM_corpse.tscn').instance()
	get_parent().add_child(corpse)
	corpse.set_pos(get_pos())
	call_deferred('queue_free')

func _set_damage_taken(what):
	damage_taken = what
	print(damage_taken)
	if damage_taken >= armor:
		die()

func _set_facing(what):
	facing = what
	emit_signal('facing_changed',facing)
	get_node('Sprite').set_frame(facing)
	

func _set_top_speed(what):
	top_speed = what
	emit_signal('top_speed_changed',top_speed)

func _set_groundID(what):
	groundID = what
	emit_signal('groundID_changed',groundID)
	self.top_speed = [80,0,65][groundID]
	

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	
	var map = get_node('../TileMap')
	var tpos = map.world_to_map(get_pos())
	var c = map.get_cell(tpos.x,tpos.y)
	if c != groundID: self.groundID = c
	
	var UP = Input.is_action_pressed('forward')
	var DOWN = Input.is_action_pressed('back')
	var LEFT = Input.is_action_pressed('turn_left')
	var RIGHT = Input.is_action_pressed('turn_right')
	
	var SHOOT = Input.is_action_pressed("shoot")
	var USE = Input.is_action_pressed('use_vehicle')
	
	var force = Vector2()
	var pulse = top_speed*delta
	
	if UP and not DOWN:
		force.y -= 1
	if DOWN and not UP:
		force.y += 1
	if LEFT and not RIGHT:
		force.x -= 1
	if RIGHT and not LEFT:
		force.x += 1
	
	if is_colliding():
		var n = get_collision_normal()
		if UP or DOWN or LEFT or RIGHT:
			force = force.slide(n)
		
		var o = get_collider()
		if o.has_method('activate'):
			if USE and not is_using:
				o.call_deferred('activate',self)
		
	force = force.normalized()*pulse
	move(force)
	
	var aimer = get_node('../Aimer')
	var mpos = get_global_mouse_pos()
	aimer.set_pos(mpos)
	var ang = get_angle_to(mpos)
	var f = round((1.0*ang) / ((2*PI)/8))
	if get_pos().x > mpos.x:
		f = 8+f
	if f==8: f=0
	if f != facing:
		self.facing = f
	
	is_using = USE
	if SHOOT:
		shoot()