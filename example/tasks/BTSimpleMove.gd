class_name BTSimpleMove extends BTMoveTaskBase

## Task that moves an agent directly toward a target
## This is simpler than path finding and doesn't use navigation

func _tick(ctx: BTContext) -> BTResult:
	if super (ctx) == BTResult.FAILURE:
		return BTResult.FAILURE

	var target_distance: float = _target_key.get_target_distance(ctx)
	if is_nan(target_distance):
		return BTResult.FAILURE

	if is_zero_approx(target_distance) or target_distance < _reached_threshold:
		return BTResult.SUCCESS

	var move_direction: Vector2 = _target_key.get_target_direction(ctx)
	if not move_direction:
		return BTResult.FAILURE

	_apply_movement(ctx, move_direction)

	if _orient_rotation_to_movement:
		_apply_rotation(ctx, move_direction)

	return BTResult.RUNNING
