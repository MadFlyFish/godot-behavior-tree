class_name BTFindPath extends BTMoveTaskBase

## Task that uses NavigationAgent2D to find and follow paths to targets
## The agent must have a NavigationAgent2D child or component

## Key used for caching the nav agent in persistent data
const NAV_AGENT_KEY = "nav_agent"

## Key for navigation agent name/path
@export var _nav_agent_path: String = "NavigationAgent2D"

func _tick(ctx: BTContext) -> BTResult:
	if super (ctx) == BTResult.FAILURE:
		return BTResult.FAILURE

	var target_position: Vector2 = _target_key.get_target_position(ctx)
	if not target_position:
		return BTResult.FAILURE

	# Get or cache navigation agent
	var persistent_data: Dictionary = ctx.get_persistent_data(self)
	var nav_agent: NavigationAgent2D

	if persistent_data.has(NAV_AGENT_KEY):
		nav_agent = persistent_data[NAV_AGENT_KEY]

		if not is_instance_valid(nav_agent):
			nav_agent = _find_nav_agent(ctx.agent)
			persistent_data[NAV_AGENT_KEY] = nav_agent
	else:
		nav_agent = _find_nav_agent(ctx.agent)
		persistent_data[NAV_AGENT_KEY] = nav_agent

	if not nav_agent:
		push_warning("BTFindPath: No NavigationAgent2D found in " + ctx.agent.name)
		return BTResult.FAILURE

	if nav_agent.target_position.distance_to(target_position) > _reached_threshold:
		nav_agent.target_position = target_position
		nav_agent.get_next_path_position() # We need to allow one frame for navigation state to update
		_apply_movement(ctx, ctx.agent.global_transform.x) # Keep moving forward
		return BTResult.RUNNING

	if nav_agent.is_navigation_finished():
		return BTResult.SUCCESS

	var path_direction: Vector2 = ctx.agent.global_position.direction_to(nav_agent.get_next_path_position())
	if not path_direction:
		return BTResult.FAILURE

	_apply_movement(ctx, path_direction)

	if _orient_rotation_to_movement:
		_apply_rotation(ctx, path_direction)

	return BTResult.RUNNING

## Helper function to find the NavigationAgent2D in an agent
func _find_nav_agent(agent: Node2D) -> NavigationAgent2D:
	if agent.has_node(_nav_agent_path):
		return agent.get_node(_nav_agent_path)
	else:
		for child in agent.get_children():
			if child is NavigationAgent2D:
				return child

	return null
