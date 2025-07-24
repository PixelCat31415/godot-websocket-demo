class_name Player
extends RigidBody2D


const MAX_VELOCITY = 300
var _is_moving: bool = false
var _velocity: Vector2 = Vector2.ZERO
var _facing: float = 0

func set_velocity(velocity: Vector2) -> void:
	if velocity.length() > 0:
		_velocity = velocity / velocity.length()
		_is_moving = true
	else:
		_velocity = velocity
		_is_moving = false

func set_facing(facing: float) -> void:
	_facing = facing

func set_look_at(target: Vector2) -> void:
	_facing = position.angle_to_point(target)


func _ready() -> void:
	pass


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _is_moving:
		state.linear_velocity = _velocity * MAX_VELOCITY
	state.transform.origin = state.transform.origin.clamp(Vector2.ZERO, get_viewport().size)
	position = state.transform.origin
	rotation = _facing


func _process(_delta: float) -> void:
	pass

