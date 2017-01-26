extends Node2D

#############################
#	WORLD NODE				#
#							#
#	Deliver the world map,	#
#	and everything in it	#
#############################



#################
#	CONSTANTS	#


#################
#	SHORTCUTS	#
onready var map = get_node('Map/VisualMap')
onready var hud = get_node('HUD')
onready var news = hud.get_node('NewsPanel/News')
onready var ents = map.get_node('Entities')

#################
#	SIGNALS		#



#################
#	PARAMS		#


#################
#	MEMBERS		#
var player

var tanks = []
var guys = []

#####################
#	PUBLIC FUNCS	#
func get_entities():
	return ents.get_children()

func get_terrainmap():
	return map.get_node('TerrainMap')

func set_map(data):
	if map.load_data(data) == OK:
		var gen = map.generate_map()



func add_tank(where=Vector2(), make_player=false):
	var tank = preload('res://Tank/Tank.tscn').instance()
	map.add_entity(tank,where)
	self.tanks.append(tank)
	if make_player:
		self.player = tank

#####################




#####################
#	PRIVATE FUNCS	#
func _ready():
	map.connect('map_changed',self,'_on_map_changed')
	var tilemap = preload('res://TerrainMap/TerrainMap.tscn').instance()
	set_map(tilemap)

#####################




#####################
#	SETTER FUNCS	#


#####################




#####################
#	SIGNAL FUNCS	#
func _on_map_changed():
	news.message("Map set: "+map.data.get_filename())

#####################