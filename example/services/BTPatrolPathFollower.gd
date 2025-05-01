class_name BTPatrolPathFollower extends BTService

## Key where the patrol points are stored in blackboard. Must be filled from outside.
@export var _patrol_points_key: StringName = "patrol_points"

## Key for storing the current patrol index in blackboard
@export var _current_index_key: StringName = "patrol_index"

## Key for storing the patrol target in blackboard (used by movement tasks)
@export var _target_point_key: StringName = "patrol_point"

## Whether to use sequential (false) or random (true) point selection
@export var _random_selection: bool = false

func _tick(ctx: BTContext) -> void:
	if not _validate_agent(ctx):
		return

	var patrol_points: Array = ctx.blackboard.get_array(_patrol_points_key)
	if patrol_points.is_empty():
		return

	assert(_assert_vector_array(patrol_points), "Patrol points must be an array of Vector2.")

	var current_index: int = 0
	if ctx.blackboard.has_key(_current_index_key):
		current_index = ctx.blackboard.get_int(_current_index_key)

	current_index = clampi(current_index, 0, patrol_points.size() - 1)

	# Pick next point index
	if _random_selection:
		if patrol_points.size() > 1:
			var new_index: int = current_index
			while new_index == current_index:
				new_index = randi() % patrol_points.size()

			current_index = new_index
	else:
		current_index = (current_index + 1) % patrol_points.size()

	ctx.blackboard.set_value(_current_index_key, current_index)
	ctx.blackboard.set_value(_target_point_key, patrol_points[current_index])

func _validate_agent(ctx: BTContext) -> bool:
	return is_instance_valid(ctx.agent) and ctx.agent is Node2D

func _assert_vector_array(patrol_points: Array) -> bool:
	return patrol_points.all(
		func(point: Variant) -> bool:
			return point is Vector2
	)
