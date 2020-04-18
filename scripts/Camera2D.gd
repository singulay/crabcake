extends Camera2D


func _ready():
	var lvl = get_parent()
	limit_left = lvl.level_min_x
	limit_top = lvl.level_min_y
	limit_right = lvl.level_max_x
	limit_bottom = lvl.level_max_y


func _process(delta):
	position = get_parent().get_node("player").position
	#print(position)
	
