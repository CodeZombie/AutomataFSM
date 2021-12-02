tool
extends GraphNode
class_name AutomataGraphNode

signal right_mouse_pressed
signal centered_offset_changed
signal on_collapse
signal on_expand
signal on_move

onready var last_size = rect_size
var mouse_hovered = false
var expanded = false

func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("resized", self, "on_resized")
	connect("offset_changed", self, "on_offset_changed")

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

func center_on_position(value):
	offset = value - rect_size/2
	
func get_centered_offset():
	return offset + rect_size/2

func on_offset_changed():
	emit_signal("on_move")
	pass
