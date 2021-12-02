#TODO:
#	Draw methods in StateMachineEditor need to honour scale
#	Having multiple StateMachineControllers in a scene breaks stuff.
#	Right clicking anywhere except a node will cancel a transition connection
#	When you save a StateMachine resource into the filesystem and then double click on it, you should
#		be able to edit it as you'd expect.
#	Add checks on every method to ensure referenced state_ids are still in the State Machine.
#	Consider removing the "State_Changed" signal from the statemachine, and just sticking
#		repopulate() methods in the StateMachineInterface methods in the editor.
#	Highlighting a statenode and transition node allows you to move the transition node. Not desired behavior.
#	TransitionNode positions dont respect zoom.
#	Consider having Nodes automatically center in the view when you open them.

tool
extends EditorPlugin
const StateMachineEditor = preload("StateMachineEditor.tscn")

# Create a statemachineeditor, which will live in memory and be placed in the
#	lower dock whenever the user selects a StateMachine in the scene.
var state_machine_editor = StateMachineEditor.instance()

func _enter_tree():
	# Triggered when the user enables the Automata plugin.
	# Allow this plugin to detect when the user has clicked on something in the scene heirarchy
	get_editor_interface().get_selection().connect("selection_changed", self, "on_selected_node_changed")

func _exit_tree():
	# Triggered when the user disables the Automata plugin.
	hide_editor()

func show_editor(state_machine_controller):
	if not state_machine_editor.is_inside_tree():
		add_control_to_bottom_panel(state_machine_editor, "Automata")
		state_machine_editor.set_state_machine_controller(state_machine_controller)
	make_bottom_panel_item_visible(state_machine_editor)
	
func hide_editor():
	if state_machine_editor.is_inside_tree():
		state_machine_editor.set_state_machine_controller(null)
		remove_control_from_bottom_panel(state_machine_editor)

func on_selected_node_changed():
	# Called when the user selects something in the scene heirarchy.
	
	# Hide the State Machine Editor in the bottom dock.
	if state_machine_editor.is_inside_tree():
		hide_editor()
	
	# If the user has selected one State Machine node, show the editor.
	var selected_nodes = get_editor_interface().get_selection().get_selected_nodes()
	if selected_nodes.size() == 1:
		if selected_nodes[0] is StateMachineController:
			show_editor(selected_nodes[0])
