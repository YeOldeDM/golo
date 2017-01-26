extends TileMap

#################################
#	VISMAP NODE					#
#								#
#	Generates a visual map,		#
#	based on its TerrainMap		#
#	child. Also manage high-	#
#	level entity functions?		#
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
func load_data(tilemap):
	if data != null:
		data.queue_free()
	data = tilemap
	add_child(data)
	data.hide()
	if data.get_parent() == self:
		return OK
	else:
		return ERR_WTF
	

func generate_map():
	var grid = data.get_used_cells()
	for pos in grid:
		set_cell(pos.x,pos.y, data.get_cell(pos.x,pos.y))

	var done = OK
	emit_signal('map_changed')
	return done

func add_entity(who,where,is_player=false):
	get_node('Entities').add_child(who)
	who.set_pos(where)
	if is_player:
		emit_signal('player_enters',who)

func remove_entity(who):
	if who.is_player():
		emit_signal('player_leaves',who)
	who.queue_free()
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
