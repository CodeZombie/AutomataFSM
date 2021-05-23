tool
extends GraphNode
class_name TransitionNode

onready var TriangleButton = $TriangleButton
var from_state_id
var to_state_id

var id setget ,get_id

func get_id():
	return str(from_state_id) + str(to_state_id)

func set_transition_ids(from_state_id, to_state_id):
	self.from_state_id = from_state_id
	self.to_state_id = to_state_id

func update_position(state_nodes):
	var from_offset = Vector2(0,0)
	var to_offset = Vector2(0,0)
	
	for state_node in state_nodes:
		if state_node.id == from_state_id:
			from_offset = state_node.get_centered_offset()
		if state_node.id == to_state_id:
			to_offset = state_node.get_centered_offset()
			
		offset = from_offset + ((to_offset - from_offset)/2) - rect_size/2
		rect_rotation = int(rad2deg(to_offset.angle_to_point(from_offset)))

