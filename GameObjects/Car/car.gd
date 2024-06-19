extends RigidBody3D
class_name Car

@export var debug := false

@export_category("Car Values")
@export var engine_power := 50.0
@export var drag := 5.0
@export var steering_angle := 45.0
@export var front_wheel_grip := 0.5
@export var rear_wheel_grip := 0.2

@export_category("Suspension Values")
@export var suspension_resting_length := 0.6
@export var suspension_strength := 500.0
@export var suspension_damper := 30.0
@export var wheel_radius := 0.3

@onready var front_left_wheel: Wheel = $WheelRaycasts/FrontLeftWheel
@onready var front_right_wheel: Wheel = $WheelRaycasts/FrontRightWheel
@onready var rear_left_wheel: Wheel = $WheelRaycasts/RearLeftWheel
@onready var rear_right_wheel: Wheel = $WheelRaycasts/RearRightWheel

var accel_input
var steering_input

func _process(delta: float) -> void:
	accel_input = Input.get_axis("accelerate", "reverse")
	steering_input = Input.get_axis("right", "left")
	
	var steering_rotation = steering_angle * steering_input
	
	if steering_rotation:
		var angle = clampf(front_left_wheel.rotation.y + steering_rotation, -steering_angle, steering_angle)
		var new_rotation = angle * delta
		
		front_left_wheel.rotation.y = lerp(front_left_wheel.rotation.y, new_rotation, 0.3)
		front_right_wheel.rotation.y = lerp(front_right_wheel.rotation.y, new_rotation, 0.3)
	else:
		front_left_wheel.rotation.y = lerp(front_left_wheel.rotation.y, 0.0, 0.3)
		front_right_wheel.rotation.y = lerp(front_right_wheel.rotation.y, 0.0, 0.3)
