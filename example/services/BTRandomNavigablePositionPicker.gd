class_name BTRandomNavigablePositionPicker extends BTService

## If provided, this will be used as the origin for the random position. Otherwise, the agent's position will be used.
@export var _origin_key: StringName

## Key for storing the random position in blackboard
@export var _random_position_key: StringName = "random_position"

## Navigation agent path (optional - if not set, will use default map)
@export var _nav_agent_path: String = "NavigationAgent2D"

## Minimum distance from agent for random point
@export var _min_distance: float = 50.0

## Maximum distance from agent for random point
@export var _max_distance: float = 300.0

## Maximum attempts to find a valid point
@export var _max_attempts: int = 10

## Whether to update the position even if navigation fails
@export var _update_on_failure: bool = false

func _tick(ctx: BTContext) -> void:
	if not is_instance_valid(ctx.agent) or not ctx.agent is Node2D:
		return

	var agent: Node2D = ctx.agent
	var position_found: bool = false
	var random_position: Vector2

	var navigation_map: RID

	var nav_agent: NavigationAgent2D = _find_nav_agent(ctx.agent)
	if nav_agent:
		navigation_map = nav_agent.get_navigation_map()
	else:
		navigation_map = NavigationServer2D.get_maps()[0]

	# Try to find a valid position
	var attempts: int = 0
	while attempts < _max_attempts and not position_found:
		attempts += 1

		var origin: Vector2 = ctx.blackboard.get_vector(_origin_key)
		if not origin:
			origin = agent.global_position

		var random_dir := Vector2.from_angle(randf() * TAU).normalized()
		var distance: float = randf_range(_min_distance, _max_distance)
		var target_position: Vector2 = origin + random_dir * distance
		var closest_point: Vector2 = NavigationServer2D.map_get_closest_point(navigation_map, target_position)
		var closest_distance: float = target_position.distance_to(closest_point)

		if closest_distance > _min_distance and closest_distance < _max_distance:
			random_position = closest_point
			position_found = true
			break

	if position_found or _update_on_failure:
		ctx.blackboard.set_value(_random_position_key, random_position)

## Helper function to find the NavigationAgent2D in an agent
func _find_nav_agent(agent: Node2D) -> NavigationAgent2D:
	if agent.has_node(_nav_agent_path):
		return agent.get_node(_nav_agent_path)
	else:
		for child in agent.get_children():
			if child is NavigationAgent2D:
				return child

	return null
