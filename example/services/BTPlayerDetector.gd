class_name BTPlayerDetector extends BTService

## Key for player detection in blackboard
@export var _player_visible_key: StringName = "is_player_visible"

## Key for storing the player reference in blackboard
@export var _player_key: StringName = "player"

## Time since last detection before rechecking
@export var _detection_memory: float = .1

## Player detection radius
@export var _detection_radius: float = 500.0

## Detection area shape - if null, uses radius instead
@export var _detection_area_path: String = ""

## Player group name
@export var _player_group: String = "player"

## Collision mask for raycasting
@export_flags_2d_physics var _collision_mask: int = 1

## Keys to objects to add to collision exception for raycasting (optional)
@export var _exclude_keys: Array[StringName]

## Groups to exclude from detection (optional)
@export var _exclude_groups: Array[StringName]

func _tick(ctx: BTContext) -> void:
	if not is_instance_valid(ctx.agent) or not ctx.agent is Node2D:
		return

	var player_visible: bool = false

	var space_state: PhysicsDirectSpaceState2D = ctx.agent.get_world_2d().direct_space_state
	var excludes: Array = [ctx.agent.get_rid()] if ctx.agent is CollisionObject2D else []
	var player: Node2D

	if _detection_area_path:
		var detection_area: Area2D = ctx.agent.get_node_or_null(_detection_area_path)
		if detection_area is Area2D:
			var overlapping_bodies: Array[Node2D] = detection_area.get_overlapping_bodies().filter(func(body): return body.is_in_group(_player_group))
			if overlapping_bodies:
				player = overlapping_bodies[0]
	else:
		var nodes: Array = ctx.agent.get_tree().get_nodes_in_group(_player_group)
		if nodes:
			player = nodes[0]

	var persistent_data: Dictionary = ctx.get_persistent_data(self)

	if player and player is Node2D:
		if _detection_area_path:
			# Line of sight check
			var query := PhysicsRayQueryParameters2D.create(
				ctx.agent.global_position,
				player.global_position,
				_collision_mask,
				excludes
			)

			query.collide_with_areas = false
			query.collide_with_bodies = true
			query.hit_from_inside = true

			# Add collision exceptions if any
			for ex in _exclude_keys:
				var node_to_exclude: Node = ctx.blackboard.get_node(ex)
				if node_to_exclude and node_to_exclude is CollisionObject2D:
					query.exclude.append(node_to_exclude.get_rid())

			for ex in _exclude_groups:
				var nodes_to_exclude: Array[Node] = ctx.agent.get_tree().get_nodes_in_group(ex)
				for node_to_exclude in nodes_to_exclude:
					if node_to_exclude and node_to_exclude is CollisionObject2D:
						query.exclude.append(node_to_exclude.get_rid())

			var result: Dictionary = space_state.intersect_ray(query)

			if result and result.collider == player:
				player_visible = true
				persistent_data[_player_key] = player
				persistent_data["last_detection_time"] = ctx.elapsed_time
		else:
			var distance: float = ctx.agent.global_position.distance_to(player.global_position)
			if distance < _detection_radius:
				player_visible = true
				persistent_data[_player_key] = player
				persistent_data["last_detection_time"] = ctx.elapsed_time

	if not player_visible and persistent_data.has("last_detection_time"):
		if ctx.elapsed_time - persistent_data["last_detection_time"] > _detection_memory:
			persistent_data.erase("last_detection_time")
			persistent_data.erase(_player_key)
		else:
			player_visible = true
			player = persistent_data[_player_key]

	ctx.blackboard.set_value(_player_visible_key, player_visible)
	if player_visible and player:
		ctx.blackboard.set_value(_player_key, player)
