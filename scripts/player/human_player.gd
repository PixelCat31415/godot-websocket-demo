class_name HumanPlayer
extends Player


func _handle_movement(_delta: float) -> void:
	var movement = Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		movement += Vector2(0, -1)
	if Input.is_key_pressed(KEY_S):
		movement += Vector2(0,  1)
	if Input.is_key_pressed(KEY_A):
		movement += Vector2(-1, 0)
	if Input.is_key_pressed(KEY_D):
		movement += Vector2( 1, 0)
	set_velocity(movement)

func _handle_facing(_delta: float) -> void:
	var target_pos = get_viewport().get_mouse_position()
	set_look_at(target_pos)

func _process(_delta: float) -> void:
	_handle_movement(_delta)
	_handle_facing(_delta)
