extends BTLeaf

export(String) var agent_method
export(String) var blackboard_key_argument



# Called after tick()
func _on_tick(result: bool):
	._on_tick(result)


func _tick(agent: Node, blackboard: Blackboard) -> bool:
	assert(agent.has_method(agent_method))
	
	if not blackboard.has_data(blackboard_key_argument):
		return fail()
	
	var result = true
	
	result = agent.call(agent_method, blackboard.get_data(blackboard_key_argument))
	
	# If action is executing, wait for completion and remain in running state
	if result is GDScriptFunctionState:
		# Store what the action returns when completed
		result = yield(result, "completed") 
	
	# If action returns anything but a bool consider it a success
	if not result is bool: 
		result = true
	
	# Once action is complete we return either success or failure.
	if result == true:
		return succeed()
	else:
		return fail()
