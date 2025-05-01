class_name BTMoveTaskBase extends BTTask

## Base class for movement-related tasks in 2D
## Provides common functionality for rotation and movement

## Target to move towards/look at
@export var _target_key: BTTargetKey

## Turn speed (interpolation factor per second)
@export var _turn_speed: float = 1.0

## Whether to orient the entity's rotation to movement direction
@export var _orient_rotation_to_movement: bool = true

## Distance at which to consider a target reached
@export var _reached_threshold: float = 20.0

## Move speed (units per second)
@export var _move_speed: float = 100.0

## Whether to slow down when near the target
@export var _slowdown_near_target: bool

## Distance at which to start slowing down
@export var _slowdown_distance: float = 200.0

## Maximum slowdown factor when close to the target
@export var _slowdown_factor: float = 0.1

## Acceleration for moving towards the target
@export var _acceleration: float = 5.0

## Friction for stopping the agent
@export var _friction: float = 10.0

# Base implementation - should be overridden by subclasses
func _tick(ctx: BTContext) -> BTResult:
	super (ctx)

	if not _validate_agent(ctx):
		return BTResult.FAILURE

	return BTResult.SUCCESS

func _post_tick(ctx: BTContext, result: BTResult) -> void:
	super (ctx, result)

	if result != BTResult.RUNNING:
		_stop_movement(ctx)

## Validate that agent is a valid Node2D
func _validate_agent(ctx: BTContext) -> bool:
	return is_instance_valid(ctx.agent) and ctx.agent is Node2D

## Apply rotation to face in a specific direction
func _apply_rotation(ctx: BTContext, direction: Vector2, success_threshold: float = 0.0) -> BTResult:
	if not direction:
		return BTResult.FAILURE

	success_threshold = abs(success_threshold)

	var agent: Node2D = ctx.agent
	agent.global_rotation = lerp_angle(agent.global_rotation, direction.angle(), clamp(_turn_speed * ctx.delta, 0, 1))

	if abs(angle_difference(agent.global_rotation, direction.angle())) <= success_threshold:
		return BTResult.SUCCESS

	return BTResult.RUNNING

## Stop movement of the agent
func _stop_movement(ctx: BTContext) -> void:
	if not _validate_agent(ctx):
		return

	var agent: Node2D = ctx.agent

	if agent is CharacterBody2D:
		_apply_movement_to_character(agent, Vector2.ZERO, 0, _friction, ctx)
	else:
		_apply_movement_to_node(agent, Vector2.ZERO, 0, _friction, ctx)

## Apply movement to any Node2D (dispatches to appropriate method)
func _apply_movement(ctx: BTContext, direction: Vector2) -> void:
	if not _validate_agent(ctx):
		return

	var agent: Node2D = ctx.agent
	var speed: float = _move_speed

	if _slowdown_near_target:
		var distance: float = _target_key.get_target_distance(ctx)
		if not is_nan(distance):
			speed = _get_scaled_speed(distance, speed)

	if agent is CharacterBody2D:
		_apply_movement_to_character(agent, direction, speed, _acceleration, ctx)
	else:
		_apply_movement_to_node(agent, direction, speed, _acceleration, ctx)

## Apply movement to a CharacterBody2D
func _apply_movement_to_character(character: CharacterBody2D, direction: Vector2, speed: float, acceleration: float, ctx: BTContext) -> void:
	var current_velocity: Vector2 = character.velocity
	var target_velocity: Vector2 = direction * speed
	character.velocity = current_velocity.lerp(target_velocity, acceleration * ctx.delta)
	character.move_and_slide()

## Apply movement to a regular Node2D
func _apply_movement_to_node(node: Node2D, direction: Vector2, speed: float, acceleration: float, ctx: BTContext) -> void:
	var current_velocity: Vector2 = ctx.blackboard.get_value("agent_velocity", Vector2.ZERO)
	var target_velocity: Vector2 = direction * speed
	var velocity: Vector2 = current_velocity.lerp(target_velocity, acceleration * ctx.delta)
	node.global_position += velocity
	ctx.blackboard.set_value("agent_velocity", velocity)

## Helper function to reduce speed when close to a target
func _get_scaled_speed(distance: float, speed: float) -> float:
	if distance > _slowdown_distance:
		return speed
	else:
		return lerp(speed * _slowdown_factor, speed, (distance - _slowdown_distance * 0.25) / _slowdown_distance)
