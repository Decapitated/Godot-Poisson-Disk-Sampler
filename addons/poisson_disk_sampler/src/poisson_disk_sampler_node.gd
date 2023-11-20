@tool
class_name PoissonDiskSampler2D extends Node2D

const point_res = preload("point.res")

@export var min_dist = 100.0:
		set(value):
			if value >= 0:
				min_dist = value
@export var max_attempts = 30

var points: Array[Vector2]

var generating = false
var gen_thread: Thread

func _process(_delta):
	var polygon: Polygon2D = get_polygon()
	var polygon_rect = get_polygon_rect(polygon)
	var cell_size = PoissonDiskSampler.get_real_cell_size(min_dist, polygon_rect)
	(polygon.material as ShaderMaterial).set_shader_parameter("cell_size", cell_size)
	(polygon.material as ShaderMaterial).set_shader_parameter("offset", polygon_rect.end - polygon_rect.size / 2.0)

func add_points():
	var polygon = get_polygon()
	if polygon != null:
		for p in points:
			var point = point_res.instantiate()
			point.position = p
			polygon.add_child(point)
			point.owner = owner
	generating = false

func clear():
	points = []
	var polygon = get_polygon()
	if polygon != null:
		for c in polygon.find_children("*", "Marker2D", false):
			polygon.remove_child(c)
			c.free()

func generate():
	if !generating:
		var polygon = get_polygon()
		if polygon != null:
			generating = true
			clear()
			gen_thread = Thread.new()
			gen_thread.start(_generate_thread.bind(polygon))
	else:
		print_rich("[color=yellow]Cannot generate; Check warnings.[/color]")

func _generate_thread(polygon: Polygon2D):
	print("Generate start.")
	var gen_start: float = Time.get_unix_time_from_system()
	var poisson_points = PoissonDiskSampler.generate_points(get_polygon_rect(polygon), min_dist, max_attempts, is_point_in_polygon.bind(polygon))
	var gen_end: float = Time.get_unix_time_from_system()
	print("Generate done. %f seconds" % (gen_end - gen_start))
	call_deferred("_on_gen_done")
	return poisson_points

func _on_gen_done():
	points = gen_thread.wait_to_finish()
	add_points()

func is_point_in_polygon(point: Vector2, polygon: Polygon2D) -> bool:
	return Geometry2D.is_point_in_polygon(point, polygon.polygon)

func _is_point_in_polygon(point: Vector2, rect: Rect2) -> bool:
	var radius = rect.size.x / 2.0
	return point.distance_squared_to(rect.size / 2.0) <= radius * radius

func get_polygon_rect(polygon: Polygon2D) -> Rect2:
	var _min: Vector2 = Vector2(INF, INF)
	var _max: Vector2 = Vector2(-INF, -INF)
	for point in polygon.polygon:
		if point.x < _min.x:
			_min.x = point.x
		if point.x > _max.x:
			_max.x = point.x
		if point.y < _min.y:
			_min.y = point.y
		if point.y > _max.y:
			_max.y = point.y

	return Rect2(_min, _max - _min)

func get_polygons() -> Array:
	return find_children("*", "Polygon2D", false)

func get_polygon() -> Polygon2D:
	var polygons = get_polygons()
	return null if polygons.is_empty() else polygons[0]

func get_world_points():
	var world_points = []
	var polygon = get_polygon()
	if polygon != null:
		world_points = points.map(func(point): return polygon.to_global(point))
	return world_points

#region Node Inspector Stuff
func _is_valid(warnings: PackedStringArray = []) -> bool:
	var polygons = get_polygons()
	if polygons.is_empty():
		warnings.append("Add a Polygon2D as a child.")
	elif (polygons[0] as Polygon2D).polygon.is_empty():
		warnings.append("Add shape data to the Polygon2D.")
	return warnings.size() == 0

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	_is_valid(warnings)
	return warnings

func _get_property_list():
	var properties = [
		{
			name = "points",
			usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY,
			type = typeof(points),
		}
	]
	return properties
#endregion
