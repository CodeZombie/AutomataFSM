#VIEW

tool
extends Control

onready var StateNode = preload("Nodes/StateNode.tscn")
onready var graphEdit = $VBoxContainer/GraphEdit
onready var NewStateButton = $VBoxContainer/HBoxContainer/NewStateButton

var ColorGreen = Color(.64, .93, .67)
var ColorRed = Color(1, .29, .27)

var state_machine_controller = null setget set_state_machine_controller

var first_state_node_right_clicked = null

#######################################
#
# User Interface methods
#
#######################################
func on_add_state_button_pressed():
	if state_machine_set():
		print("Adding new state...")
		state_machine_controller.state_machine.add_state("New State")

func state_node_right_clicked(state_node):
	if first_state_node_right_clicked == null:
		first_state_node_right_clicked = state_node
	else:
		add_transition(first_state_node_right_clicked, state_node)
		first_state_node_right_clicked = null
		
#######################################
#
# Core Methods
#
#######################################
func add_state_node(state):
	var newStateNode = StateNode.instance()
	newStateNode.id = state["id"]
	newStateNode.state_name = state["name"]
	newStateNode.offset = state["position"]
	newStateNode.connect("right_mouse_pressed", self, "state_node_right_clicked")
	newStateNode.connect("show_properties", self, "on_state_graphnode_expanded")
	newStateNode.connect("change_state_name", self, "on_state_name_changed")
	graphEdit.add_child(newStateNode)
	
func on_state_name_changed(state_id, new_name):
	state_machine_controller.state_machine.set_state_name(state_id, new_name)
	
func update_nodegraph_state(state):
	var node = get_graphnode_by_state_id(state["id"])
	node.state_name = state["name"]
	node.offset = state["position"]
	
func add_transition(from, to):
	if not state_machine_set():
		return
		
	if from == to:
		return
		
	state_machine_controller.state_machine.add_transition(from.id, to.id)

func get_graphnode_by_state_id(id):
	for graphnode in get_all_state_graphnodes():
		if graphnode.id == id:
			return graphnode
	return null
	
func get_all_state_graphnodes():
	var out = []
	for node in graphEdit.get_children():
		if node is StateGraphNode:
			out.push_back(node)
	return out
	
func state_machine_set():
	if state_machine_controller == null or state_machine_controller.state_machine == null:
		return false
	return true

func delete_state_graphnode(id):
	var node = get_graphnode_by_state_id(id)
	graphEdit.remove_child(node)
	node.queue_free()

func depopulate():
	for state_node in get_all_state_graphnodes():
		graphEdit.remove_child(state_node)
		state_node.queue_free()

func populate():
	if not state_machine_set():
		return
	
	var state_ids = []
	
	for state in state_machine_controller.state_machine.states:
		state_ids.push_back(state["id"])
		if get_graphnode_by_state_id(state["id"]) == null:
			add_state_node(state)
		else:
			update_nodegraph_state(state)
	
	for node in get_all_state_graphnodes():
		if state_ids.find(node.id) == -1:
			delete_state_graphnode(node.id)

func graph_node_moved():
	for state_node in get_all_state_graphnodes():
		state_machine_controller.state_machine.set_state_position(state_node.id, state_node.offset)
	populate()
	
func on_state_graphnode_expanded():
	for state_node in get_all_state_graphnodes():
		state_node.hide_properties()
#######################################
#
# System Methods
#
#######################################

func _draw():
	var margin_size = 3 * graphEdit.zoom
	if first_state_node_right_clicked != null:
		var to_pos = get_local_mouse_position() - graphEdit.rect_position
		var from_pos = first_state_node_right_clicked.rect_position + (first_state_node_right_clicked.rect_size/2) * graphEdit.zoom
		var from_pos_edge = get_line_rect_intersection_point(first_state_node_right_clicked.rect_position + Vector2(margin_size, margin_size), first_state_node_right_clicked.rect_position + first_state_node_right_clicked.rect_size * graphEdit.zoom - Vector2(margin_size, margin_size), from_pos, to_pos)
		graphEdit.add_line(from_pos_edge, to_pos, ColorGreen, 3)
		graphEdit.add_circle(to_pos, 8 * graphEdit.zoom, ColorGreen)
		graphEdit.add_circle(from_pos_edge, 8 * graphEdit.zoom, ColorGreen)
	if state_machine_set():
		for state in state_machine_controller.state_machine.states:
			for transition in state["transitions"]:
				var from_graphnode = get_graphnode_by_state_id(state["id"])
				var to_graphnode = get_graphnode_by_state_id(transition["to_state_id"])
				var from_node_position = from_graphnode.rect_position
				var to_node_position = to_graphnode.rect_position 
				var from_pos = from_node_position + (from_graphnode.rect_size/2) * graphEdit.zoom
				var to_pos = to_node_position + (to_graphnode.rect_size/2) * graphEdit.zoom
				
				var line_start = get_line_rect_intersection_point(from_node_position + Vector2(margin_size,margin_size), from_node_position + from_graphnode.rect_size * graphEdit.zoom - Vector2(margin_size,margin_size), from_pos, to_pos)
				var line_end = get_line_rect_intersection_point(to_node_position + Vector2(margin_size,margin_size), to_node_position + to_graphnode.rect_size * graphEdit.zoom - Vector2(margin_size,margin_size), to_pos, from_pos)
				graphEdit.add_line(line_start, line_end, ColorGreen, 4 * graphEdit.zoom)
				graphEdit.add_circle(line_start, 8 * graphEdit.zoom, ColorGreen)
				graphEdit.add_circle(line_end, 8 * graphEdit.zoom, ColorGreen)

func _process(dt):
	update()
	
func _ready():
	NewStateButton.connect("pressed", self, "on_add_state_button_pressed")
	graphEdit.connect("_end_node_move", self, "graph_node_moved")
	
func _enter_tree():
	graphEdit = $VBoxContainer/GraphEdit
	
func _exit_tree():
	state_machine_controller = null
	
func set_state_machine_controller(value):
	if state_machine_set():
		print("Disconnecting states_changed signal")
		state_machine_controller.state_machine.disconnect("states_changed", self, "populate")
		
	state_machine_controller = value
	
	if state_machine_set():
		print("Connecting states_changed signal")
		state_machine_controller.state_machine.connect("states_changed", self, "populate")
		
	populate()
	
#######################################
#
# Helper methods
#
#######################################
func get_line_rect_intersection_point(rect_topleft, rect_bottomright, line_a, line_b):
	var rect_topright = Vector2(rect_bottomright.x, rect_topleft.y)
	var rect_bottomleft = Vector2(rect_topleft.x, rect_bottomright.y)
	
	var line_dir = (line_a - line_b).normalized()
	var points = []
	
	var top = Geometry.line_intersects_line_2d(rect_topleft, (rect_topleft - rect_topright).normalized(), line_a, line_dir)
	if top != null and top.x > rect_topleft.x and top.x < rect_topright.x:
		points.push_back(top)
		
	var left = Geometry.line_intersects_line_2d(rect_topleft, (rect_topleft - rect_bottomleft).normalized(),line_a, line_dir)
	if left != null and left.y < rect_bottomleft.y and left.y > rect_topleft.y:
		points.push_back(left)
		
	var right = Geometry.line_intersects_line_2d(rect_topright, (rect_topright - rect_bottomright).normalized(), line_a, line_dir)
	if right != null and right.y < rect_bottomleft.y and right.y > rect_topright.y:
		points.push_back(right)
	
	var bottom = Geometry.line_intersects_line_2d(rect_bottomleft, (rect_bottomleft - rect_bottomright).normalized(), line_a, line_dir)
	if bottom != null and bottom.x > rect_bottomleft.x and bottom.x < rect_bottomright.x:
		points.push_back(bottom)
		
	if not points.empty():
		var closest = points[0]	
		for point in points:
			if point.distance_to(line_b) <= closest.distance_to(line_b):
				closest = point
		return closest
	
	return Vector2(0,0)
