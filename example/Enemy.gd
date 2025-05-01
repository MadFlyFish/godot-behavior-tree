extends CharacterBody2D

@export var bt: BehaviorTree
@export var patrol_path: Node2D

var ctx: BTContext
var _run_bt: bool

# To be called for example by Level or AI manager. You can handle this depending on your game logic.
func run_behavior_tree() -> void:
	if not is_instance_valid(bt):
		return

	_run_bt = true
	ctx = bt.create_context(self, Blackboard.new())

	if patrol_path:
		var patrol_points: Array = []

		for patrol_pt in patrol_path.get_children():
			patrol_points.append(patrol_pt.global_position)

		ctx.blackboard.set_value("patrol_points", patrol_points)

func _physics_process(delta: float) -> void:
	if not (is_instance_valid(bt) and _run_bt):
		return

	bt.tick(ctx, delta)
