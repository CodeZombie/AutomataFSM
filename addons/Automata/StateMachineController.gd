#CONTROLLER 

extends Node
class_name StateMachineController

export (Resource) var state_machine

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#This should format StateMachine as a class and send that instead.
func get_state_machine():
	return state_machine
