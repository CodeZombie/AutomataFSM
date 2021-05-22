#MODEL
tool
extends Resource
class_name StateMachine

signal states_changed

export(Array, Dictionary) var states setget set_states

func set_states(value):
	states = value
	delete_dead_transitions()
	emit_signal("states_changed")

#### TRANSITIONS
func add_transition(from_state_id, to_state_id):
	var new_transition = {
		"to_state_id": to_state_id,
		"conditions": []
	}
	
	var state = get_state_by_id(from_state_id)
	state["transitions"].push_back(new_transition)
	emit_signal("states_changed")

### STATES
func add_state(state_name):
	var id = get_new_unique_id(0)
	var new_state = {
		"name": state_name,
		"id": id,
		"on_enter_method": "",
		"on_update_method": "",
		"on_exit_method": "",
		"transitions": [],
		"position": Vector2(0,0),
	}
	states.push_back(new_state)
	emit_signal("states_changed")
	return id

func delete_dead_transitions():
	for state in states:
		for i in range(state["transitions"].size() - 1, -1, -1):
			if get_state_by_id(state["transitions"][i]["to_state_id"]) == null:
				state["transitions"].remove(i)

func delete_state(state_id):
	for state in states:
		if state["id"] == state_id:
			var i = states.find(state)
			states.remove(i)
			emit_signal("states_changed")
	delete_dead_transitions()


func set_state_position(state_id, position):
	for state in states:
		if state["id"] == state_id:
			state["position"] = position

func set_state_name(state_id, name):
	for state in states:
		if state["id"] == state_id:
			state["name"] = name
			emit_signal("states_changed")

func get_state_by_id(id):
	for state in states:
		if state["id"] == id:
			return state
	return null
	
func get_new_unique_id(id):
	for state in states:
		if state["id"] == id:
			return get_new_unique_id(id + 1)
	return id
