tool
extends GraphNode
class_name StateGraphNode

signal right_mouse_pressed
signal show_properties

signal change_state_name

onready var state_name_label = $ContentContainer/TitleContainer/StateNameLabel
onready var properties_container = $ContentContainer/PropertiesContainer
onready var title_container = $ContentContainer/TitleContainer
onready var title_lineedit = $ContentContainer/PropertiesContainer/state_name_lineedit
onready var close_button = $ContentContainer/PropertiesContainer/close_button

var mouse_hovered = false

var id
var state_name setget set_state_name


func set_state_name(val):
	state_name = val
	if state_name_label != null:
		state_name_label.text = val
	if title_lineedit != null and title_lineedit.text != val:
		title_lineedit.text = val
	#propagate to state_machine_editor which will propogate up to state_machine
	
	
func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	title_lineedit.connect("text_changed", self, "on_title_lineedit_text_changed")
	close_button.connect("pressed", self, "hide_properties")
	
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
	title_container.hide()
	properties_container.show()
	rect_size.x = 250
	rect_size.y = 0
