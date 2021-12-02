tool
extends AutomataGraphNode
class_name TransitionNode

# Refactor todo:
# 1. This node should not know about its to/from statenodes or their positions.
#		All position updates should be called fro mthe Editor when a State changes position.
# 2. This node needs to inherit from AutomataGraphNode.
# 3. ID formatting is incorrect. from.id() + to.id() is wrong.
#		"1025" is ambiguous between 10->25 and 102->5. Add a delineator.
# 4. Set position with `center_on_position()`
# 5. Remove the `properties_shown` method. This functionality is available through `expanded` bool
# 6. 

#signal set_state_node_positions

onready var TriangleButtonContainer = $ContentContainer/TriangleButtonContainer
onready var TriangleButton = $ContentContainer/TriangleButtonContainer/TriangleButton
onready var PropertiesContainer = $ContentContainer/PropertiesContainer
var from_state_id
var to_state_id

var from_state_node_position = Vector2(0,0)
var to_state_node_position = Vector2(0,0)

var id setget ,get_id

func _ready():
	TriangleButton.connect("pressed", self, "on_triangle_button_pressed")
	#connect("set_state_node_positions", self, "update_position")
	connect("on_expand", self, "show_properties")
	connect("on_collapse", self, "hide_properties")

func on_triangle_button_pressed():
	_expand()
	
func initialize(from_node, to_node):
	# Set ID from nodes
	# Set position from nodes
	pass

func show_properties():
	TriangleButtonContainer.hide()
	PropertiesContainer.show()
	rect_size.x = 250
	rect_size.y = 0
	#update_position()

func hide_properties():
	PropertiesContainer.hide()
	TriangleButtonContainer.show()
	rect_size.x = 0
	rect_size.y = 0
	#update_position()

func get_id():
	return str(from_state_id) + str(to_state_id)

func set_transition_ids(from_state_id, to_state_id):
	self.from_state_id = from_state_id
	self.to_state_id = to_state_id

func properties_shown():
	return PropertiesContainer.visible

func set_state_node_positions(state_nodes):
	for state_node in state_nodes:
		if state_node.id == from_state_id:
			from_state_node_position = state_node.get_centered_offset()
		if state_node.id == to_state_id:
			to_state_node_position = state_node.get_centered_offset()
	emit_signal("set_state_node_positions")

#func update_position():
#	offset = from_state_node_position + ((to_state_node_position - from_state_node_position)/2) - rect_size/2
#	if not properties_shown():
#		rect_rotation = int(rad2deg(to_state_node_position.angle_to_point(from_state_node_position)))
#	else:
#		rect_rotation = 0
		
func set_position_as_center(from_node, to_node):
	offset = from_node.get_centered_offset() + ((to_node.get_centered_offset() - from_node.get_centered_offset())/2) - rect_size/2
	if not expanded:
		rect_rotation = int(rad2deg(to_node.get_centered_offset().angle_to_point(from_node.get_centered_offset())))
	else:
		rect_rotation = 0

func _process(delta):
	if selected:
		selected = false
	

