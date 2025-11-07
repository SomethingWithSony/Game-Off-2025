extends StaticBody3D
class_name Block

@export var health : float = 10

@onready var area : Area3D = $Area3D
@onready var mesh_instance : MeshInstance3D = $MeshInstance3D

var is_placed : bool = false
var can_be_placed : bool = true

func _ready():
	if mesh_instance.mesh:
		mesh_instance.mesh = mesh_instance.mesh.duplicate()
		
		var mat = mesh_instance.get_active_material(0)
		if mat:
			mesh_instance.set_surface_override_material(0, mat.duplicate())
		
	
func _process(_delta):
	var overlapping = area.get_overlapping_bodies()
	can_be_placed = overlapping.filter(func(b): return b is Block).is_empty()
	var material = mesh_instance.get_surface_override_material(0)

	material.albedo_color = Color.BLUE if can_be_placed else Color.RED
	mesh_instance.set_surface_override_material(0, material)

func place():
	if can_be_placed:
		collision_layer = 8
		is_placed = true
