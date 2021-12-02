tool
extends GraphNode
class_name AutomataGraphNode
# IMPORTANT:
#	GraphNodes have to types of position values:
#	offset: The relative position within the GraphEdit area. 
#		Use this for positioning Nodes in the GraphEdit.
#		Does not require Zoom scaling.

#	rect_position: the absolute pixel value on the screen.
#		Use this for drawing on top of the GraphEdit.
#		Requires zoom scaling.

# The child elements within this scene must have their Mouse Filter set 
#	to Pass or else the node will not be able to detect hovering correctly.

signal right_mouse_pressed
signal centered_offset_changed
signal on_collapse
signal on_expand

onready var last_size = rect_size
var mouse_hovered = false
var expanded = false

func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("resized", self, "on_resized")

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.is_pressed() and not event.is_echo():
			if mouse_hovered:
				emit_signal("right_mouse_pressed", self)
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.doubleclick:
		if mouse_hovered:
			_expand()
	if expanded and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and mouse_hovered == false:
			_collapse()

func _expand():
	expanded = true
	emit_signal("on_expand")
	
func _collapse():
	expanded = false
	emit_signal("on_collapse")
	
func _on_mouse_entered():
	mouse_hovered = true
	
func _on_mouse_exited():
	mouse_hovered = false

func on_resized():
	offset += last_size/2 - rect_size/2
	last_size = rect_size

func center_on_relative_position(value):
	offset = value - rect_size/2

func get_absolute_center(zoom):
	return rect_position + (rect_size/2) * zoom
	
func get_relative_center():
	return offset + (rect_size/2)

func position_between(from_pos, to_pos, zoom):
	offset = from_pos + ((to_pos - from_pos)/2) - (rect_pivot_offset * (1/zoom))
