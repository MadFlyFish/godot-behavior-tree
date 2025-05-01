extends CharacterBody2D

@export var speed: float = 200.0

func _physics_process(delta: float) -> void:
	var move_dir := Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		move_dir.x += 1
	if Input.is_action_pressed("ui_left"):
		move_dir.x -= 1
	if Input.is_action_pressed("ui_down"):
		move_dir.y += 1
	if Input.is_action_pressed("ui_up"):
		move_dir.y -= 1

	if move_dir.length() > 0:
		velocity = velocity.lerp(move_dir.normalized() * speed, 5 * delta)
		global_rotation = lerp_angle(global_rotation, velocity.angle(), 10 * delta)
	else:
		velocity = velocity.lerp(Vector2.ZERO, 20 * delta)

	move_and_slide()
