tool
extends GraphNode
class_name StateGraphNode

signal right_mouse_pressed
signal show_properties
signal delete_button_pressed

signal change_state_name
signal centered_offset_changed

onready var state_name_label = $ContentContainer/TitleContainer/StateNameLabel
onready var properties_container = $ContentContainer/PropertiesContainer
onready var title_container = $ContentContainer/TitleContainer
onready var title_lineedit = $ContentContainer/PropertiesContainer/state_name_lineedit
onready var delete_button = $ContentContainer/PropertiesContainer/button_container/delete_button
onready var okay_button = $ContentContainer/PropertiesContainer/button_container/save_button
var mouse_hovered = false

var id
var state_name setget set_state_name
onready var last_size = rect_size

func on_offset_changed():
	emit_signal("centered_offset_changed", id)

func center_on_position(value):
	offset = value - rect_size/2
	
func get_centered_offset():
	return offset + rect_size/2
	
func set_state_name(val):
	state_name = val
	if state_name_label != null:
		state_name_label.text = val
	if title_lineedit != null and title_lineedit.text != val:
		title_lineedit.text = val
	
func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	title_lineedit.connect("text_changed", self, "on_title_lineedit_text_changed")
	okay_button.connect("pressed", self, "hide_properties")
	delete_button.connect("pressed", self, "delete_button_pressed")
	connect("resized", self, "on_resize")
	connect("offset_changed", self, "on_offset_changed")
	
	hide_properties()
	set_state_name(state_name)
	
func on_title_lineedit_text_changed(val):
	set_state_name(title_lineedit.text)
	emit_signal("change_state_name", id, title_lineedit.text)

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.is_pressed() and not event.is_echo():
			if mouse_hovered:
				emit_signal("right_mouse_pressed", self)
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.doubleclick:
		if mouse_hovered:
			show_properties()

func _on_mouse_entered():
	mouse_hovered = true
	
func _on_mouse_exited():
	mouse_hovered = false
	
func hide_properties():
	properties_container.hide()
	rect_size.x = 0
	rect_size.y = 0
	title_container.show()
	
func show_properties():
	emit_signal("show_properties")
	var original_rect_size = rect_size
	title_container.hide()
	properties_container.show()
	rect_size.x = 250
	rect_size.y = 0

func delete_button_pressed():
	emit_signal("delete_button_pressed", id)
	
func on_resize():
	offset += last_size/2 - rect_size/2
	last_size = rect_size

func _process(delta):
	title = str(offset)
