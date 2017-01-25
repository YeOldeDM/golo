extends TileMap

#################################
#	VISMAP NODE					#
#								#
#	Generates a visual map,		#
#	based on its TerrainMap		#
#	child. Also manage high-	#
#	level entity functions.		#
#################################



#################
#	CONSTANTS	#


#################
#	SHORTCUTS	#
onready var ents = get_node('Entities')


#################
#	SIGNALS		#
signal player_enters(who)
signal player_leaves(who)
signal map_changed()

#################
#	PARAMS		#


#################
#	MEMBERS		#
var data

#####################
#	PUBLIC FUNCS	#
func generate_map(dat):
	self.data = dat
	var done = OK
	emit_signal('map_changed')
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
