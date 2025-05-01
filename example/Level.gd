extends Node2D

func _ready() -> void:
	randomize()

	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.run_behavior_tree()
