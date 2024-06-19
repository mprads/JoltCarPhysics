extends RayCast3D
class_name Wheel

@onready var car: Car = get_parent().get_parent()


var previous_suspension_length := 0.0


func _ready() -> void:
	add_exception(car)


func _physics_process(delta: float) -> void:
	if is_colliding():
		var suspension_direction: Vector3 = global_basis.y
		var raycast_origin: Vector3 = global_position
		var raycast_point: Vector3 = get_collision_point()
		var distance := raycast_point.distance_to(raycast_origin)
	
		var contact := raycast_point - car.global_position
		
		var suspension_compressed_length := clampf(distance - car.wheel_radius, 0, car.suspension_resting_length)
		var recoil_force := car.suspension_strength * (car.suspension_resting_length - suspension_compressed_length)
		
		var suspension_velocity := (previous_suspension_length - suspension_compressed_length) / delta
		
		var damper_force := car.suspension_damper * suspension_velocity
		
		var suspension_force := basis.y * (recoil_force + damper_force)

		previous_suspension_length = suspension_compressed_length
		
		var point := Vector3(raycast_point.x, raycast_point.y + car.wheel_radius, raycast_point.z)
		
		car.apply_force(suspension_direction * suspension_force, point - car.global_position)
		
		if car.debug:
			#DebugDraw3D.draw_sphere(point, 0.1)
			DebugDraw3D.draw_arrow(global_position, to_global(position + Vector3(-position.x, (suspension_force.y / 2), -position.z)), Color.GREEN, 0.1, true)
			DebugDraw3D.draw_line_hit_offset(global_position, to_global(position + Vector3(-position.x, -1, -position.z)), true, distance, 0.2, Color.RED, Color.RED)
