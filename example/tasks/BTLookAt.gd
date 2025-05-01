class_name BTLookAt extends BTMoveTaskBase

## Task that rotates an agent to face a target
## The agent must be a Node2D

## Minimum angle difference to consider success (in radians)
@export var _min_angle: float = 0.01

func _tick(ctx: BTContext) -> BTResult:
	if super (ctx) == BTResult.FAILURE:
		return BTResult.FAILURE

	var target_direction: Vector2 = _target_key.get_target_direction(ctx)
	if not target_direction:
		return BTResult.FAILURE

	_stop_movement(ctx)

	return _apply_rotation(ctx, target_direction, _min_angle)
