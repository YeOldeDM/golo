extends KinematicBody2D

signal top_speed_changed(what)
var top_speed = 150 setget _set_top_speed

signal speed_changed(what)
var current_speed = 0.0 setget _set_current_speed


var max_turn_rate = 0.7
signal top_turn_rate_changed(what)
var top_turn_rate setget _set_top_turn_rate

signal turn_rate_changed(what)
var current_turn_rate = 0.0 setget _set_current_turn_rate

var acceleration = 25
var turn_acceleration = 0.6

var turret_fov = 120

var turret_turn_rate = 3.4

var min_aim_range = 40

var friction = 2.0


var is_shooting=false

var team = 0

signal groundID_changed(what)
var groundID = -1 setget _set_groundID

var armor = 150
var damage_taken = 0 setget _set_damage_taken

func take_damage(source):
	var dmg = source.damage
	self.damage_taken = damage_taken+dmg
	
	var v = source.get_global_transform().y*source.damage
	move(v)

func die():
	print("YOU ESPLODE")

func get_target_pos():
	return get_node('../Aimer').get_pos()

func _set_current_turn_rate(what):
	current_turn_rate = min(what,top_turn_rate)
	emit_signal('turn_rate_changed',current_turn_rate)

func _set_top_turn_rate(what):
	top_turn_rate = what
	emit_signal('top_turn_rate_changed',top_turn_rate)
	
func _set_top_speed(what):
	top_speed = what
	emit_signal('top_speed_changed',top_speed)

func _set_current_speed(what):
	current_speed = what
	emit_signal('speed_changed',current_speed)

func _set_groundID(what):
	if what == groundID:return
	groundID = what
	self.top_speed = [120,0,100][groundID]
	emit_signal('groundID_changed',groundID)

func _ready():
	get_node('ArmorRight').set_max(armor)
	get_node('ArmorRight').set_value(damage_taken)
	get_node('ArmorLeft').set_max(armor)
	get_node('ArmorLeft').set_value(damage_taken)
	set_fixed_process(true)
	




func _fixed_process(delta):
	
	var map = get_node('../TileMap')
	var map_pos = map.world_to_map(get_pos())
	var newground = map.get_cell(map_pos.x,map_pos.y)
	if newground != groundID: self.groundID = newground
	
	var FORWARD = Input.is_action_pressed('forward')
	var BACK = Input.is_action_pressed('back')
	var LEFT = Input.is_action_pressed('turn_left')
	var RIGHT = Input.is_action_pressed('turn_right')
	
	var SHOOT = Input.is_action_pressed('shoot')
	
	# Get forward vector
	var tr = get_transform().y
	
	# Accelerate
	if FORWARD and current_speed <= top_speed:
		self.current_speed += min(acceleration*delta, top_speed-current_speed)
	# Decelerate/Reverse (at half speed)
	elif BACK and current_speed >= -top_speed*0.5:
		self.current_speed -= min(acceleration*delta*2, top_speed-current_speed)
	# Dampen toward Zero if no input
	else:
		var s = sign(current_speed)
		var v = abs(current_speed)
		v -= acceleration * delta * friction
		self.current_speed = s*max(0,v)
	
	# Decrease turn rate as speed increases
	self.top_turn_rate = max_turn_rate * (1.0-abs(current_speed)/top_speed)
	
	# Steer counter-clockwise
	if LEFT and current_turn_rate < top_turn_rate:
		self.current_turn_rate += turn_acceleration * delta
	# Steer clockwise
	elif RIGHT and current_turn_rate > - top_turn_rate:
		self.current_turn_rate -= turn_acceleration * delta
	# Dampen toward Zero if no input
	else:
		var s = sign(current_turn_rate)
		var v = abs(current_turn_rate)
		v -= turn_acceleration * delta * friction
		self.current_turn_rate = s*max(0,v)
	
	# Apply linear force
	var motion = move(tr*delta*current_speed)
	# Prevent wall-humping acceleration
	self.current_speed -= motion.length()*sign(current_speed)
	
	# Apply angular force
	rotate(delta*current_turn_rate)
	
	# Aim the turret
	# get
	var mpos = get_global_mouse_pos()
	var ang = get_node('Turret').get_angle_to(mpos)
	# set
	get_node('Turret').rotate(ang*delta*turret_turn_rate)
	get_node('../Aimer').set_pos(mpos)
	
	# Shoot a bullet
	if SHOOT and !is_shooting:
		get_node('Weapon').Fire()
	is_shooting = SHOOT
	
	# Offset camera to follow
	# A point ahead of current motion
	# vector.
	var cam_offset = tr*current_speed
	# effect offset to follow mouse
	cam_offset += (mpos - get_pos())/5
	get_node('Camera').set_offset(cam_offset)
	
	if abs(current_speed) > 0.02:
		for node in get_node('Tracks').get_children():
			node.set_emitting(true)
	else:
		for node in get_node('Tracks').get_children():
			node.set_emitting(false)
	
func _set_damage_taken(what):
	damage_taken = what
	if damage_taken > armor:
		die()
	
	get_node('ArmorRight').set_value(damage_taken)
	get_node('ArmorLeft').set_value(damage_taken)