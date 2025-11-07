extends CharacterBody3D
class_name Player

# Health
@export var max_health : float = 100
@export var health : float = 100

# Movement
@export var movement_speed : float = 5.0
@export var forward_acceleration : float = 10.0
@export var backward_acceleration : float = forward_acceleration * 0.4
@export var deaceleration : float = 8.0
var direction : Vector2 

# Camera
@onready var camera_controller : Node3D = $CameraController
@onready var camera_target = $CameraController/CameraTarget
@onready var camera : Camera3D = $CameraController/CameraTarget/Camera3D
@export var camera_follow_lag : float = 0.15

func _physics_process(delta):
	var mouse_pos = get_viewport().get_mouse_position()

	movement_logic(delta, mouse_pos)
	move_and_slide()
	
	camera_follow()
	
# Camera & Movement
func movement_logic(delta, mouse_pos):
	if direction == Vector2.ZERO:
		velocity = velocity.move_toward(Vector3.ZERO, deaceleration * delta)
		
	direction = Input.get_vector("left", "right", "forward", "back").rotated(-rotation.y)
	var new_velocity : Vector3 = Vector3(direction.x, 0, direction.y) * movement_speed
	var acceleration : float
	
	if direction == Vector2.DOWN:
		acceleration = backward_acceleration * delta
	else: 
		acceleration = forward_acceleration * delta
		
	velocity = velocity.move_toward(new_velocity, acceleration)
	
	var ray: Dictionary  = cast_ray(mouse_pos, 50)
	
	if !ray.is_empty():

		var look_target : Vector3 = Vector3(ray.position.x, position.y, ray.position.z)
		var player_target_vector : Vector3 = (look_target - position).normalized()
		var angle_rad : float = atan2(-player_target_vector.x, -player_target_vector.z)
		rotation.y = lerp_angle(rotation.y, angle_rad, 10 * delta)

func camera_follow():
	camera_controller.global_position = lerp(camera_controller.global_position, global_position, camera_follow_lag)
	#camera_controller.rotation.y = lerp_angle(camera_controller.global_rotation.y , rotation.y, 0.01) 
	
# Utils
func cast_ray(mouse_pos : Vector2, ray_length : int) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var origin = camera.project_ray_origin(mouse_pos)
	var end = origin + camera.project_ray_normal(mouse_pos) * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	
	var result = space_state.intersect_ray(query)
	
	return result
		
