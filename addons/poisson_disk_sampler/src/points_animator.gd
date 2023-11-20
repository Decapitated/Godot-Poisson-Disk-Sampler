class_name PointsAnimator extends Node2D

const real_point = preload("real_point.res")

@onready var point_sampler: PoissonDiskSampler2D = get_parent()

@export_range(0.0, 1.0) var index_scaled = 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	var global_points = point_sampler.get_world_points()
	for global_point in global_points:
		var point = to_local(global_point)
		var point_res: Sprite2D = real_point.instantiate()
		point_res.position = point
		point_res.visible = false
		var color_index = randi() % 3
		var color: Color = Color(0.0, 0.0, 0.0)
		if color_index == 0:
			color = Color(1.0, 0.0, 0.0)
		elif color_index == 1:
			color = Color(0.0, 1.0, 0.0)
		elif color_index == 2:
			color = Color(0.0, 0.0, 1.0)
		(point_res.material as ShaderMaterial).set_shader_parameter("color", color)
		add_child(point_res)
		point_res.owner = owner


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var i = 0
	for c in find_children("*", "Sprite2D", false):
		(c as Sprite2D).visible = i <= int((point_sampler.points.size() - 1) * index_scaled)
		i += 1
