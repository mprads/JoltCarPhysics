extends RigidBody3D
class_name Car

@export var debug := false

@export_category("Suspension Values")
@export var suspension_resting_length := 0.5
@export var suspension_strength := 10.0
@export var suspension_damper := 2.0
@export var wheel_radius := 0.5
