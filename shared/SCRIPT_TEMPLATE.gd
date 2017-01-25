
extends Node	# or Whatever!

#############################
#	NODE NAME				#
#							#
#	Short description of	#
#	this script's function	#
#							#
#############################



#################
#	CONSTANTS	#


#################
#	SHORTCUTS	#
#onready var NameLabel = get_node('NameLabel')


#################
#	SIGNALS		#
#signal name_changed()


#################
#	PARAMS		#
#export(String) var name = "Bob" setget _set_name, _get_name

#################
#	MEMBERS		#


#####################
#	PUBLIC FUNCS	#

#func set_name(new_name):
#	if new_name != name:
#		self.name = new_name
#
#func get_name():
#	return self.name
#####################


#####################
#	PRIVATE FUNCS	#

#func _ready():
#	connect("name_changed", self, "_on_name_changed")
#####################


#####################
#	SETTER FUNCS	#

#func _set_name(what):
#	name = what
#	emit_signal("name_changed")
#
#func _get_name():
#	return name
#####################


#####################
#	SIGNAL FUNCS	#

#func _on_name_changed():
#	print("I changed my name to" + name)
#####################