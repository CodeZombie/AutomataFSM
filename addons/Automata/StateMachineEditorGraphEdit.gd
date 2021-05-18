tool
extends GraphEdit

var lines = []
var circles = []

func add_line(from, to, color, width):
	lines.push_back([from, to, color, width])
	
func add_circle(position, radius, color):
	circles.push_back([position, radius, color])
	
func _draw():
	for line in lines:
		#from, to, color, width, anti-aliasing
		draw_line(line[0], line[1], line[2], line[3], true)
		
	for circle in circles:
		#position, radius, color
		draw_circle(circle[0], circle[1], circle[2])

func _process(dt):
	update()
	lines.clear()
	circles.clear()
