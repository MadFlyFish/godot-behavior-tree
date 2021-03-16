class_name BTDecorator, "res://addons/behavior_tree/icons/btdecorator.svg"
extends BTNode

# Accepts only ONE child. Ticks and sets its state the same as the child.
# Can be used to create conditions.

onready var bt_child: BTNode = get_child(0) as BTNode



func _ready():
	assert(get_child_count() == 1)


# BEGINNING OF VIRTUAL FUNCTIONS
# Override these in your extended script (check template for example)

# Called after tick()
func _on_tick(result: bool):
	._on_tick(result)


func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var result = bt_child.tick(agent, blackboard)
	
	if result is GDScriptFunctionState:
		result = yield(result, "completed")
	
	return set_state(bt_child)

# END OF VIRTUAL FUNCTIONS


