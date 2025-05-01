class_name RandomLookDirectionPicker extends BTService

## Key for storing the random direction in blackboard
@export var _direction_key: StringName = "random_look_direction"

## Minimum angle change in radians
@export var _min_angle_change: float = PI / 6

## Maximum angle change in radians
@export var _max_angle_change: float = PI

## Whether to use absolute angles instead of relative to current direction
@export var _use_absolute_angles: bool = false

## Limit direction to specific sectors (in radians from forward)
@export var _sector_angles: Array[float]

## Amplitude of the sector angles (in radians)
@export var _sector_amplitude: float = PI / 6

func _tick(ctx: BTContext) -> void:
	if not is_instance_valid(ctx.agent) or not ctx.agent is Node2D:
		return

	var current_direction: Vector2 = ctx.agent.global_transform.x.normalized()
	var new_direction: Vector2

	if _use_absolute_angles:
		if _sector_angles.is_empty():
			var random_angle: float = randf() * TAU
			new_direction = Vector2(cos(random_angle), sin(random_angle))
		else:
			# Pick a random sector
			var sector_index: int = randi() % _sector_angles.size()
			var base_angle: float = _sector_angles[sector_index]
			var random_angle: float = base_angle + randf_range(-1, 1) * _sector_amplitude
			new_direction = Vector2(cos(random_angle), sin(random_angle))
	else:
		# Generate a random relative angle
		var current_angle: float = current_direction.angle()
		var angle_change: float = randf_range(_min_angle_change, _max_angle_change)
		if randf() > 0.5:
			angle_change = - angle_change

		var new_angle: float = current_angle + angle_change
		new_direction = Vector2.from_angle(new_angle)

	ctx.blackboard.set_value(_direction_key, new_direction)
