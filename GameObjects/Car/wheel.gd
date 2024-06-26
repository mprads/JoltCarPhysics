extends RayCast3D
class_name Wheel

@export var is_front_wheel := false

@onready var car: Car = get_parent().get_parent()

var previous_suspension_length := 0.0


func _ready() -> void:
	add_exception(car)


func _physics_process(delta: float) -> void:
	if is_colliding():
		_suspension(delta, get_collision_point())
		_apply_lateral_force(delta, get_collision_point())
		if !is_front_wheel:
			_acceleration(get_collision_point())


func _apply_resistance(collision_point: Vector3) -> void:
	var direction := global_basis.z
	var state := PhysicsServer3D.body_get_direct_state(car.get_rid())
	var wheel_velocity := state.get_velocity_at_local_position(global_position - car.global_position)
	var resistance = direction.dot(wheel_velocity) * car.mass / car.drag
	
	car.apply_force(-direction * resistance, collision_point - car.global_position)
	var point := Vector3(collision_point.x, collision_point.y + car.wheel_radius, collision_point.z)
	
	if car.debug:
		DebugDraw3D.draw_arrow(point, point + (-direction * resistance / 20), Color.YELLOW, 0.1, true)


func _apply_lateral_force(delta: float, collision_point: Vector3) -> void:
	var direction := global_basis.x
	var state := PhysicsServer3D.body_get_direct_state(car.get_rid())
	var wheel_velocity := state.get_velocity_at_local_position(global_position - car.global_position)
	var later_velocity := direction.dot(wheel_velocity)
	
	var grip := car.rear_wheel_grip
	
	if is_front_wheel:
		grip = car.front_wheel_grip
	
	var desired_velocity_change := -later_velocity * grip
	var lateral_force = desired_velocity_change / delta
	
	car.apply_force(direction * lateral_force, collision_point - car.global_position)
	
	if car.debug:
		DebugDraw3D.draw_arrow(global_position, global_position + (direction * lateral_force / 20), Color.PURPLE, 0.1, true)


func _acceleration(collision_point: Vector3) -> void:
	var accel_direction := -global_basis.z
	
	var torque = car.accel_input * car.engine_power
	var point := Vector3(collision_point.x, collision_point.y + car.wheel_radius, collision_point.z)
	
	if torque:
		car.apply_force(accel_direction * torque, point - car.global_position)
	else :
		_apply_resistance(collision_point)
	
	if car.debug:
		DebugDraw3D.draw_arrow(point, point + (accel_direction * torque / 20), Color.BLUE, 0.1, true)


func _suspension(delta: float, collision_point: Vector3) -> void:
	var suspension_direction: Vector3 = global_basis.y
	var raycast_origin: Vector3 = global_position
	var distance := collision_point.distance_to(raycast_origin)

	var contact := collision_point - car.global_position
	
	var suspension_compressed_length := clampf(distance - car.wheel_radius, 0, car.suspension_resting_length)
	var recoil_force := car.suspension_strength * (car.suspension_resting_length - suspension_compressed_length)
	
	var suspension_velocity := (previous_suspension_length - suspension_compressed_length) / delta
	var damper_force := car.suspension_damper * suspension_velocity
	var suspension_force := basis.y * (recoil_force + damper_force)

	previous_suspension_length = suspension_compressed_length
	
	var point := Vector3(collision_point.x, collision_point.y + car.wheel_radius, collision_point.z)
	
	car.apply_force(suspension_direction * suspension_force, point - car.global_position)
	
	if car.debug:
		#DebugDraw3D.draw_sphere(point, 0.1)
		DebugDraw3D.draw_arrow(global_position, to_global(position + Vector3(-position.x, (suspension_force.y / 20), -position.z)), Color.GREEN, 0.1, true)
		DebugDraw3D.draw_line_hit_offset(global_position, to_global(position + Vector3(-position.x, -1, -position.z)), true, distance, 0.2, Color.RED, Color.RED)


func _get_point_velcocity(point: Vector3) -> Vector3:
	return car.linear_velocity + car.angular_velocity.cross(point - car.global_position)
