#TODO:
#	Draw methods in StateMachineEditor need to honour scale
#	Draw commands need to be placed in a CanvasItem above the GraphEdit.
#	Any "New State" created should be placed in the center of the viewport
#	Expanding states should keep them centered in the same location
#	Right clicking anywhere except a node will cancel a transition connection
#	When you save a StateMachine resource into the filesystem and then double click on it, you should
#		be able to edit it as you'd expect.
#	Add checks on every method to ensure referenced state_ids are still in the State Machine.

tool
extends EditorPlugin
const StateMachineEditor = preload("StateMachineEditor.tscn")

var state_machine_editor = StateMachineEditor.instance()
var editor_selection

func _enter_tree():
	editor_selection = get_editor_interface().get_selection()
	editor_selection.connect("selection_changed", self, "on_selected_node_changed")

func _exit_tree():
	pass

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
	var selected_nodes = editor_selection.get_selected_nodes()
	if selected_nodes.size() == 1:
		if selected_nodes[0] is StateMachineController:
			show_editor(selected_nodes[0])
		else:
			hide_editor()
