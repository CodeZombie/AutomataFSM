tool
extends GraphEdit

export var transition_line_width = 4
export var transition_terminal_radius = 8

var lines = []
var circles = []

func add_line(from, to, color):
	lines.push_back([from, to, color])
	
func add_circle(position, color):
	circles.push_back([position, color])
	
func _draw():
	for line in lines:
		#from, to, color, width, anti-aliasing
		draw_line(line[0], line[1], line[2], transition_line_width * zoom, true)
		
	for circle in circles:
		#position, radius, color
		draw_circle(circle[0], transition_terminal_radius * zoom, circle[1])

func _process(dt):
	update()
	lines.clear()
	circles.clear()
