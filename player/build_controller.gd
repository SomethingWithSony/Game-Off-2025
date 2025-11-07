extends Node3D

@onready var camera : Camera3D = $"../CameraController/CameraTarget/Camera3D"

var cell_size = .5

# Temporary Buidling - Prototype
@export var is_building_mode_activated : bool = false
@onready var block : PackedScene = preload("res://blocks/block.tscn")
var current_block : Block = null

# Rotation
var last_block_orientation : Vector3 = Vector3.ZERO

func _physics_process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	# Bulding Logic Tests
	if is_building_mode_activated:
		place_block(mouse_pos)
		
func place_block(mouse_pos: Vector2):
	var root = get_tree().root.get_children()[0]

	if !current_block:
		current_block = block.instantiate()
		current_block.rotation = last_block_orientation
		root.add_child(current_block)
	
	var space_state = get_world_3d().direct_space_state
	var origin = camera.project_ray_origin(mouse_pos)
	var end = origin + camera.project_ray_normal(mouse_pos) * 50 # * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var all_layers = (1 << 20) - 1      # assume 20 physics layers exist
	var collision_masks = all_layers & ~(1 << 4)   # remove bit for layer 5
	query.collision_mask = collision_masks
	var ray = space_state.intersect_ray(query)
		
	if !ray.is_empty():
		var look_target : Vector3 = ray.position
		current_block.global_position = snap_to_grid(look_target)
		
		if Input.is_action_just_pressed("mouse1"):
			current_block.place()
			if current_block.can_be_placed:
				current_block = null
							
		if Input.is_action_just_pressed("rotate"):
			current_block.rotate(Vector3.UP, deg_to_rad(90))
			last_block_orientation = current_block.rotation
			
func snap_to_grid(pos: Vector3) -> Vector3:
	return Vector3(
		round(pos.x / cell_size) * cell_size,
		round(pos.y / cell_size) * cell_size,
		round(pos.z / cell_size) * cell_size
		)
