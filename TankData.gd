extends PanelContainer

func _ready():
	pass
	sync(get_node('/root/Main/Tank'))

func sync(to):
	to.connect('speed_changed',self,'_on_speed_changed')
	to.connect('top_speed_changed',self,'_on_top_speed_changed')
	to.connect('groundID_changed',self,'_on_ground_changed')
	to.connect('turn_rate_changed',self,'_on_turn_rate_changed')
	to.connect('top_turn_rate_changed',self,'_on_top_turn_rate_changed')

func _on_speed_changed(what):
	get_node('box/Speed/Value').set_text(str(ceil(what)))

func _on_top_speed_changed(what):
	get_node('box/Speed/Max').set_text(str(int(what)))

func _on_ground_changed(what):
	get_node('box/Ground/Value').set_text(['Road','Wall','Grass'][what])

func _on_turn_rate_changed(what):
	get_node('box/TurnRate/Value').set_text(str(abs(ceil(rad2deg(what)))))

func _on_top_turn_rate_changed(what):
	get_node('box/TurnRate/Max').set_text(str(int(rad2deg(what))))