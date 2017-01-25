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
onready var hud = get_node('Hud')
onready var ents = map.get_node('Entities')

#################
#	SIGNALS		#



#################
#	PARAMS		#


#################
#	MEMBERS		#


#####################
#	PUBLIC FUNCS	#
func get_entities():
	return ents.get_children()

func get_terrainmap():
	return map.get_node('TerrainMap')

func set_map(data):
	var done = map.generate_map(data)
	return done
#####################




#####################
#	PRIVATE FUNCS	#


#####################




#####################
#	SETTER FUNCS	#


#####################




#####################
#	SIGNAL FUNCS	#


#####################