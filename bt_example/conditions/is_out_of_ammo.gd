extends BTDecorator

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	assert("ammo" in agent)
	
	if agent.ammo <= 0:
		print("\tsuccess")
		return ._tick(agent, blackboard)
	else:
		print("\tfailed")
		return fail()
