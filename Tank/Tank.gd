extends KinematicBody2D

var laserbeam = preload('res://laser/LaserBeam.tscn')

var max_speed = 240
var damage_speed_factor = 1.0
signal top_speed_changed(what)
var top_speed = 300 setget _set_top_speed

signal speed_changed(what)
var current_speed = 0.0 setget _set_current_speed

var drive_fx_speed = 1.0 setget _set_drive_fx_speed
var track_anim_speeds = [0.0, 0.0] setget _set_track_anim_speeds

var min_turn_rate = 0.3
var max_turn_rate = 2.2

signal top_turn_rate_changed(what)
var top_turn_rate = 1.0 setget _set_top_turn_rate

signal turn_rate_changed(what)
var current_turn_rate = 0.0 setget _set_current_turn_rate

var acceleration = 50
var turn_acceleration = 1.5

var turret_fov = 120
var turret_rot = 0 setget _set_turret_rot

var turret_turn_rate = 5.4

var min_aim_range = 40



var is_shooting=false

var team = 0

signal can_deploy(what)
var can_deploy = false setget _set_can_deploy
var active = true

signal groundID_changed(what)
var groundID = -1 setget _set_groundID
var terrain_on = {'name':'NA','speed':1.0,'friction':1.0}

var armor = 150
var damage_taken = 0 setget _set_damage_taken

var is_using = false

var laser




func activate(lgm=null):
	get_node('Camera').make_current()
	self.active = true
	if lgm:
		lgm.call_deferred('deactivate')


func deactivate():
	self.active = false

func exit_tank():
	if can_deploy:
		var pos = get_pos() - (get_global_transform().y*48)
		var lgm = preload('res://LGM.tscn').instance()
		get_parent().add_child(lgm)
		lgm.set_pos(pos)
		lgm.call_deferred('activate',self)
	
func take_damage(source):
	var dmg = source.damage
	self.damage_taken = damage_taken+dmg
	
	var v = source.get_global_transform().y*source.damage
	move(v)


func shoot():
	var aimer = get_node('../Aimer')
	var turret = get_node('Turret')
	var tr = turret.get_global_transform()
	var origin = tr.o + (tr.y*48)
	var angle = turret.get_rot()+get_rot()
	var distance = get_pos().distance_to(aimer.get_pos())-48
	get_node('Weapon').Fire(origin,angle,distance)

func die():
	get_parent().get_node('Spectator').call_deferred('activate',self)

func kill():
	var corpse = preload('res://Tank/TankCorpse.tscn').instance()
	get_parent().add_child(corpse)
	corpse.set_transform(get_transform())
	call_deferred('queue_free')

func get_target_pos():
	return get_node('../Aimer').get_pos()



func _fixed_process(delta):
	# Check exit point clearance
	self.can_deploy = get_node('LGMDeploy').get_overlapping_bodies().empty()
	
	# Get map position
	var map = get_node('../TileMap')
	var map_pos = map.world_to_map(get_pos())
	
	# Get/set ground surface
	var newground = map.get_cell(map_pos.x,map_pos.y)
	if newground != groundID: self.groundID = newground
	
	# Input flags
	var FORWARD = Input.is_action_pressed('forward')
	var BACK = Input.is_action_pressed('back')
	var LEFT = Input.is_action_pressed('turn_left')
	var RIGHT = Input.is_action_pressed('turn_right')
	var SHOOT = Input.is_action_pressed('shoot')
	var USE = Input.is_action_pressed('use_vehicle')
	
	# Get forward vector
	var tr = get_transform().y
	
	# Get/set top speed
	var new_top_speed = max_speed * terrain_on.speed * damage_speed_factor
	if new_top_speed != self.top_speed:
		self.top_speed = new_top_speed
	
	# Get current speed
	var new_current_speed = self.current_speed
	
	# Accelerate
	if active and FORWARD and current_speed <= top_speed:
		new_current_speed += min(acceleration*delta, top_speed-current_speed)
	
	# Decelerate/Reverse
	elif active and BACK and current_speed >= -top_speed*0.75:
		new_current_speed -= min(acceleration*delta, top_speed-current_speed)
	
	# Dampen toward Zero if no input or over top speed
	else:
		var s = sign(current_speed)
		var v = abs(current_speed)
		v -= delta * terrain_on.friction
		new_current_speed = s*max(0,v)


	new_current_speed = clamp(new_current_speed,-top_speed, top_speed)
	# Set current speed
	if new_current_speed != self.current_speed:
		self.current_speed = new_current_speed
	
	# Get top turn rate. Decrease turn rate as speed increases
	var new_top_turn_rate = max_turn_rate * max(min_turn_rate,1.0-abs(current_speed)/top_speed)
	# Get current turn rate
	var new_turn_rate = self.current_turn_rate
	
	# Steer counter-clockwise
	if active and LEFT and current_turn_rate < top_turn_rate:
		new_turn_rate += min(turn_acceleration * delta, top_turn_rate - current_turn_rate)
	
	# Steer clockwise
	elif active and RIGHT and current_turn_rate > -top_turn_rate:
		new_turn_rate -= min(turn_acceleration * delta, top_turn_rate - current_turn_rate)
	
	# Dampen turning toward Zero if no input or speeding
	else:
		var s = sign(current_turn_rate)
		var v = abs(current_turn_rate)
		v -= delta * terrain_on.friction
		new_turn_rate = s*max(0,v)
	
	# Set top turn rate
	if new_top_turn_rate != self.top_turn_rate:
		self.top_turn_rate = new_top_turn_rate
	
	# Set current turn rate
	new_turn_rate = min(new_turn_rate, top_turn_rate)
	if new_turn_rate != self.current_turn_rate:
		self.current_turn_rate = new_turn_rate
	
	# Apply linear force
	var motion = move(tr*delta*current_speed)
	# Convert extra motion to speed decrease
	self.current_speed -= motion.length()*sign(current_speed)
	
	# Apply angular force
	rotate(delta*current_turn_rate)
	
	if active:
		# Aim the turret
		# get
		var mpos = get_global_mouse_pos()
		var ang = get_node('Turret').get_angle_to(mpos)
		var rot = get_node('Turret').get_rot()
		# set
		rot += (ang*delta*turret_turn_rate)
		self.turret_rot = clamp(rot,deg2rad(-turret_fov),deg2rad(turret_fov))
		# get_node('Turret').rotate(ang*delta*turret_turn_rate)
		get_node('../Aimer').set_pos(mpos)
		
		# Shoot a bullet
		
		if !is_shooting and SHOOT:
			shoot()
		is_shooting = SHOOT
		
		# Offset camera to follow
		# A point ahead of current motion
		# vector.
		var cam_offset = tr*current_speed*0.5
		# effect offset to follow mouse
		cam_offset += (mpos - get_pos())/5
		get_node('Camera').set_offset(cam_offset)
	
	# Manage trackprint emitters
	if abs(current_speed) > 0.02:
		for node in get_node('Tracks').get_children():
			node.set_emitting(true)
	else:
		for node in get_node('Tracks').get_children():
			node.set_emitting(false)
	

	
	
	# Use_vehicle interaction..
	if active and USE and not is_using:
		exit_tank()
	is_using = USE




func _set_damage_taken(what):
	damage_taken = what
	self.damage_speed_factor = lerp(0.25,1.0,1.0-(damage_taken/armor))
	if damage_taken > armor:
		die()
	
	get_node('ArmorRight').set_value(damage_taken)
	get_node('ArmorLeft').set_value(damage_taken)


func _set_turret_rot(what):
	turret_rot = what
	get_node('Turret').set_rot(turret_rot)


func _set_drive_fx_speed(what):
	drive_fx_speed = what
	get_node('SfxDrive').set('params/pitch_scale', drive_fx_speed)

func _set_track_anim_speeds(what):
	track_anim_speeds = what
	if track_anim_speeds[0] != get_node('TrackLeft/Animator').get_speed():
		get_node('TrackLeft/Animator').set_speed(track_anim_speeds[0])
	if track_anim_speeds[1] != get_node('TrackRight/Animator').get_speed():
		get_node('TrackRight/Animator').set_speed(track_anim_speeds[1])


func _set_current_turn_rate(what):
	current_turn_rate = min(what,top_turn_rate)
	emit_signal('turn_rate_changed',current_turn_rate)
	
	var new_drive_fx_speed = lerp(0.5,1.25, (abs(current_speed) / max_speed)+ (abs(current_turn_rate)/8))
	if new_drive_fx_speed != drive_fx_speed:
		self.drive_fx_speed = new_drive_fx_speed

func _set_can_deploy(what):
	can_deploy = what
	emit_signal('can_deploy',can_deploy)

func _set_top_turn_rate(what):
	top_turn_rate = what
	emit_signal('top_turn_rate_changed',top_turn_rate)
	
func _set_top_speed(what):
	top_speed = what
	emit_signal('top_speed_changed',top_speed)

func _set_current_speed(what):
	current_speed = what
	emit_signal('speed_changed',current_speed)
	var new_track_anim_left = (current_speed/64)+(current_turn_rate)
	var new_track_anim_right = (current_speed/64)+(-current_turn_rate)
	if new_track_anim_left != track_anim_speeds[0]:
		self.track_anim_speeds[0] = new_track_anim_left
	if new_track_anim_right != track_anim_speeds[1]:
		self.track_anim_speeds[1] = new_track_anim_right
	
	var new_drive_fx_speed = lerp(0.5,1.25, (abs(current_speed) / max_speed)+ (abs(current_turn_rate)/8))
	if new_drive_fx_speed != drive_fx_speed:
		self.drive_fx_speed = new_drive_fx_speed
	
func _set_groundID(what):
	if what == groundID:return
	groundID = what
	self.terrain_on = Game.terrain[groundID]
	emit_signal('groundID_changed',groundID)

func _ready():
	get_node('ArmorRight').set_max(armor)
	get_node('ArmorRight').set_value(damage_taken)
	get_node('ArmorLeft').set_max(armor)
	get_node('ArmorLeft').set_value(damage_taken)
	set_fixed_process(true)
	get_node('SfxDrive').play('tank_drive')