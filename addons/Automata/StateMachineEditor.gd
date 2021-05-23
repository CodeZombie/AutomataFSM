#VIEW

tool
extends Control

onready var State_Node = preload("Nodes/StateNode.tscn")
onready var Transition_Node = preload("Nodes/TransitionNode.tscn")
onready var Graph_Edit = $VBoxContainer/GraphEdit
onready var New_State_Button = $VBoxContainer/HBoxContainer/NewStateButton

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
	create_state()
	
func delete_state_node_button_pressed(id):
	delete_state(id)
	
func state_node_right_clicked(state_node):
	if first_state_node_right_clicked == null:
		first_state_node_right_clicked = state_node
	else:
		add_transition(first_state_node_right_clicked, state_node)
		first_state_node_right_clicked = null

func on_state_node_moved():
	update_state_positions()
	update_transition_positions()
	
func on_state_graphnode_expanded():
	for state_node in get_all_state_nodes():
		state_node.hide_properties()
		
func on_state_name_changed(state_id, new_name):
	update_state_name(state_id, new_name)
	
#######################################
#
# State Machine Interface
#
#######################################

func create_state():
	if state_machine_set():
		var initial_position = Graph_Edit.scroll_offset + (Graph_Edit.rect_size/2)
		state_machine_controller.state_machine.add_state("New State", initial_position)

func delete_state(id):
	state_machine_controller.state_machine.delete_state(id)
	
func update_state_positions():
	for state_node in get_all_state_nodes():
		state_machine_controller.state_machine.set_state_position(state_node.id, state_node.offset)
	
func update_state_name(state_id, new_name):
	state_machine_controller.state_machine.set_state_name(state_id, new_name)
	
func add_transition(from, to):
	if not state_machine_set():
		return
	if from == to:
		return
	state_machine_controller.state_machine.add_transition(from.id, to.id)
	
#######################################
#
# Editor Core Methods
#
#######################################
func add_state_node(state):
	var newStateNode = State_Node.instance()
	newStateNode.id = state["id"]
	newStateNode.state_name = state["name"]
	newStateNode.offset = state["position"]
	newStateNode.connect("right_mouse_pressed", self, "state_node_right_clicked")
	newStateNode.connect("show_properties", self, "on_state_graphnode_expanded")
	newStateNode.connect("change_state_name", self, "on_state_name_changed")
	newStateNode.connect("delete_button_pressed", self, "delete_state_node_button_pressed")
	newStateNode.connect("offset_changed", self, "on_state_node_moved")
	Graph_Edit.add_child(newStateNode)

func delete_state_node(id):
	var state_node = get_state_node_by_id(id)
	Graph_Edit.remove_child(state_node)
	state_node.queue_free()
	
func get_state_node_by_id(id):
	for graphnode in get_all_state_nodes():
		if graphnode.id == id:
			return graphnode
	return null
	
func get_all_state_nodes():
	var out = []
	for node in Graph_Edit.get_children():
		if node is StateGraphNode:
			out.push_back(node)
	return out
	
	
	
func create_transition_node(from_state_id, transition):
	print("Creating transition node")
	#get the two state nodes this transition touches
	#find the middle point between the two of them
	#transition nodes will be responsible for positioning and rotation themselves
	var from_state_node = get_state_node_by_id(from_state_id)
	var to_state_node = get_state_node_by_id(transition["to_state_id"])
	var newTransitionNode = Transition_Node.instance()
	newTransitionNode.set_transition_ids(from_state_node.id, to_state_node.id)
	newTransitionNode.update_position(get_all_state_nodes())
	Graph_Edit.add_child(newTransitionNode)
		

	
func update_state_node(state):
	var node = get_state_node_by_id(state["id"])
	if node.state_name != state["name"]:
		node.state_name = state["name"]
		
	if node.offset != state["position"]:
		node.offset = state["position"]
	



	
func get_all_transition_nodes():
	var out = []
	for node in Graph_Edit.get_children():
		if node is TransitionNode:
			out.push_back(node)
	return out
	
func state_machine_set():
	if state_machine_controller == null or state_machine_controller.state_machine == null:
		return false
	return true
	
func update_transition_positions():
	for transition_node in get_all_transition_nodes():
		transition_node.update_position(get_all_state_nodes())

func populate(): #rename to populate_gra
	if not state_machine_set():
		return
	
	var state_ids = []
	
	#Find all states and corresponding statenodes, updating them if they exist, and creating them if they don't.
	for state in state_machine_controller.state_machine.states:
		state_ids.push_back(state["id"])
		if get_state_node_by_id(state["id"]) == null:
			add_state_node(state)
		else:
			update_state_node(state)
	
	#Delete all statenodes that no longer have a corresponding state.
	for node in get_all_state_nodes():
		if state_ids.find(node.id) == -1:
			delete_state_node(node.id)
	
	#Delete all transition nodes
	for transition_node in get_all_transition_nodes():
		Graph_Edit.remove_child(transition_node)
		transition_node.queue_free()
	
	#Create all transition nodes.
	for state in state_machine_controller.state_machine.states:
		for transition in state["transitions"]:
			create_transition_node(state["id"], transition)
	

#######################################
#
# System Methods
#
#######################################

func _draw():
	var margin_size = 3 * Graph_Edit.zoom
	if first_state_node_right_clicked != null:
		var to_pos = get_local_mouse_position() - Graph_Edit.rect_position
		var from_pos = first_state_node_right_clicked.rect_position + (first_state_node_right_clicked.rect_size/2) * Graph_Edit.zoom
		var from_pos_edge = get_line_rect_intersection_point(first_state_node_right_clicked.rect_position + Vector2(margin_size, margin_size), first_state_node_right_clicked.rect_position + first_state_node_right_clicked.rect_size * Graph_Edit.zoom - Vector2(margin_size, margin_size), from_pos, to_pos)
		Graph_Edit.add_line(from_pos_edge, to_pos, ColorGreen)
		Graph_Edit.add_circle(to_pos, ColorGreen)
		Graph_Edit.add_circle(from_pos_edge, ColorGreen)
		
	if state_machine_set():
		for state in state_machine_controller.state_machine.states:
			for transition in state["transitions"]:
				var from_graphnode = get_state_node_by_id(state["id"])
				var to_graphnode = get_state_node_by_id(transition["to_state_id"])
				var from_node_position = from_graphnode.rect_position
				var to_node_position = to_graphnode.rect_position 
				var from_pos = from_node_position + (from_graphnode.rect_size/2) * Graph_Edit.zoom
				var to_pos = to_node_position + (to_graphnode.rect_size/2) * Graph_Edit.zoom
				
				var line_start = get_line_rect_intersection_point(from_node_position + Vector2(margin_size,margin_size), from_node_position + from_graphnode.rect_size * Graph_Edit.zoom - Vector2(margin_size,margin_size), from_pos, to_pos)
				var line_end = get_line_rect_intersection_point(to_node_position + Vector2(margin_size,margin_size), to_node_position + to_graphnode.rect_size * Graph_Edit.zoom - Vector2(margin_size,margin_size), to_pos, from_pos)
				Graph_Edit.add_line(line_start, line_end, ColorGreen)
				Graph_Edit.add_circle(line_start,  ColorGreen)
				Graph_Edit.add_circle(line_end, ColorGreen)

func _process(dt):
	update()
	
func _ready():
	print("READY")
	New_State_Button.connect("pressed", self, "on_add_state_button_pressed")
	#Graph_Edit.connect("_end_node_move", self, "on_state_node_moved")
	
func _enter_tree():
	print("Enter Tree")
	pass
	
func _exit_tree():
	print("Exit Tree")
	state_machine_controller = null
	
func set_state_machine_controller(value):
	#Disconnect signals from the previously set state_machine if one was set
	#Connect signals to the new state_machine.
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
