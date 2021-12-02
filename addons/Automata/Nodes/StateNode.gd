tool
extends AutomataGraphNode
class_name StateGraphNode

signal show_properties
signal delete_button_pressed

signal change_state_name

onready var state_name_label = $ContentContainer/TitleContainer/StateNameLabel
onready var properties_container = $ContentContainer/PropertiesContainer
onready var title_container = $ContentContainer/TitleContainer
onready var title_lineedit = $ContentContainer/PropertiesContainer/state_name_lineedit
onready var delete_button = $ContentContainer/PropertiesContainer/button_container/delete_button
onready var okay_button = $ContentContainer/PropertiesContainer/button_container/save_button


var id
var state_name setget set_state_name

	
func set_state_name(val):
	state_name = val
	if state_name_label != null:
		state_name_label.text = val
	if title_lineedit != null and title_lineedit.text != val:
		title_lineedit.text = val
	
func _ready():
	title_lineedit.connect("text_changed", self, "on_title_lineedit_text_changed")
	okay_button.connect("pressed", self, "hide_properties")
	delete_button.connect("pressed", self, "delete_button_pressed")
	connect("on_expand", self, "show_properties")
	connect("on_collapse", self, "hide_properties")
	set_state_name(state_name)
	hide_properties()
	
func on_title_lineedit_text_changed(val):
	set_state_name(title_lineedit.text)
	emit_signal("change_state_name", id, title_lineedit.text)

func hide_properties():
	properties_container.hide()
	title_container.show()
	rect_size.x = 0
	rect_size.y = 0
	
func show_properties():
	emit_signal("show_properties")
	var original_rect_size = rect_size
	title_container.hide()
	properties_container.show()
	rect_size.x = 250
	rect_size.y = 0

func delete_button_pressed():
	emit_signal("delete_button_pressed", id)
	
