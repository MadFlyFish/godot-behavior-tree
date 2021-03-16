extends BTDecorator


export(String) var agent_property
export(String) var blackboard_key



func _on_tick(result: bool):
	._on_tick(result)


func _tick(agent: Node, blackboard: Blackboard) -> bool:
	assert(agent_property in agent)
	
	if not blackboard.has_data(blackboard_key):
		return fail()
	
	# If condition is met, tick the child (default decorator tick mode)
	if agent.get(agent_property) and blackboard.get_data(blackboard_key):
		print("\t success")
		return ._tick(agent, blackboard)
	else:
		print("\t failure")
		return fail()
