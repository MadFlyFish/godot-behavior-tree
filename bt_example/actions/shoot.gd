extends BTLeaf


func _on_tick(result: bool):
	print("\t" + ("success" if result else "failed"))


func _tick(agent: Node, blackboard: Blackboard) -> bool:
	if agent.ammo <= 0:
		return fail()
	
	yield(get_tree().create_timer(.4, false), "timeout")
	agent.ammo -= 1
	
	return succeed()
