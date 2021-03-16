extends BTLeaf



# Called after tick()
func _on_tick(result: bool):
	print("\t" + ("successful" if result else "failed"))



func _tick(agent: Node, blackboard: Blackboard) -> bool:
	assert(agent.has_method("my_method"))
	
	if not blackboard.has_data("my_key"):
		return fail()
	
	var result = true
	
	result = agent.call("my_method", blackboard.get_data("my_key"))
	
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
