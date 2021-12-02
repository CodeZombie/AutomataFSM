tool
extends AutomataGraphNode
class_name TransitionNode

# Refactor todo:
# 1. This node should not know about its to/from statenodes or their positions.
#		All position updates should be called from the Editor when a State changes position.
# 2. This node needs to inherit from AutomataGraphNode.
# 3. ID formatting is incorrect. from.id() + to.id() is wrong.
#		"1025" is ambiguous between 10->25 and 102->5. Add a delineator.
# 4. Set position with `center_on_relative_position()`
# 5. Remove the `properties_shown` method. This functionality is available through `expanded` bool
# 6. 

#signal set_state_node_positions

onready var TriangleButtonContainer = $ContentContainer/TriangleButtonContainer
onready var TriangleButton = $ContentContainer/TriangleButtonContainer/TriangleButton
onready var PropertiesContainer = $ContentContainer/PropertiesContainer
var from_state_id
var to_state_id
var old_rotation = 0

var id setget ,get_id

func _ready():
	TriangleButton.connect("pressed", self, "on_triangle_button_pressed")
	#connect("set_state_node_positions", self, "update_position")
	connect("on_expand", self, "show_properties")
	connect("on_collapse", self, "hide_properties")
	
func get_id():#
	return str(from_state_id) + "_" + str(to_state_id)
func _expand():
	print("Expand prior")
	old_rotation = rect_rotation
	rect_rotation = 0
	._expand()
	
func _collapse():
	print("Collapse prior")
	rect_rotation = old_rotation
	._collapse()

func on_triangle_button_pressed():
	_expand()
	
func initialize(from_node, to_node, zoom):
	from_state_id = from_node.id
	to_state_id = to_node.id
	self.position_between(from_node.get_relative_center(), to_node.get_relative_center(), zoom)

func show_properties():
	TriangleButtonContainer.hide()
	PropertiesContainer.show()
	rect_size.x = 250
	rect_size.y = 0

func hide_properties():
	PropertiesContainer.hide()
	TriangleButtonContainer.show()
	rect_size.x = 0
	rect_size.y = 0

func position_between(from_pos, to_pos, zoom):
	.position_between(from_pos, to_pos, zoom)
	if not expanded:
		rect_rotation = int(rad2deg(to_pos.angle_to_point(from_pos)))
	else:
		rect_rotation = 0

func _process(delta):
	if selected:
		selected = false
	

