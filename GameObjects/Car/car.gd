extends RigidBody3D
class_name Car

@export var debug := false

@export_category("Car Values")
@export var engine_power := 2.0

@export_category("Suspension Values")
@export var suspension_resting_length := 0.5
@export var suspension_strength := 10.0
@export var suspension_damper := 2.0
@export var wheel_radius := 0.5

var accel_input

func _process(delta: float) -> void:
	accel_input = Input.get_axis("accelerate", "reverse")
