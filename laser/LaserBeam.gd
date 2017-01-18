extends Polygon2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_process_input(true)


func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		var mpos = get_node('/root/Main/Aimer').get_global_pos()
		rotate(get_angle_to(mpos))
		var D = get_global_pos().distance_to(mpos)
		print(D)
		var poly = get_polygon()
		var uv = get_uv()
		poly[2].y = D
		poly[3].y = D
		uv[2].y = D
		uv[3].y = D
		set_polygon(poly)
		#set_uv(uv)
		for node in get_children():
			if node extends Polygon2D:
				var poly = node.get_polygon()
				var uv = node.get_uv()
				poly[2].y = D
				poly[3].y = D
				uv[2].y = D
				uv[3].y = D
				node.set_polygon(poly)
				#node.set_uv(uv)

