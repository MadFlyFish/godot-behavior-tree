extends BTDecorator



func _on_tick(result: bool):
	pass


func _tick(agent: Node, blackboard: Blackboard) -> bool:
	assert("my_property" in agent)
	
	if not blackboard.has_data("my_key"):
		return fail()
	
	# If condition is met, tick the child (default decorator tick mode)
	if agent.get("my_property") and blackboard.get_data("my_key"):
		print("\t successful")
		return ._tick(agent, blackboard) # Base method ticks the child
	else:
		print("\t failed")
		return fail()
