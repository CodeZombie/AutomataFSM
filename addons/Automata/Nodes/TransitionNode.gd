tool
extends GraphNode
class_name TransitionNode

var from_state_id
var to_state_id

func set_transition_ids(from_state_id, to_state_id):
	self.from_state_id = from_state_id
	self.to_state_id = to_state_id

func update_position(state_nodes):
	var from_offset = Vector2(0,0)
	var to_offset = Vector2(0,0)
	
	for state_node in state_nodes:
		if state_node.id == from_state_id:
			from_offset = state_node.offset
		if state_node.id == to_state_id:
			to_offset = state_node.offset
			
		offset = from_offset + ((to_offset - from_offset)/2)
