@tool
class_name PoissonDiskSampler2D extends Node2D

const point_res = preload("point.res")

@export var points: Array[Vector2] = []
@export var point_holder: Node2D
@export var min_dist = 100.0:
	set(value):
		if value >= 0:
			min_dist = value
@export var max_attempts = 30

var generating = false
var gen_thread: Thread

var polygon: Polygon2D

func add_points():
	point_holder = Node2D.new()
	point_holder.name = "PointHolder"
	point_holder.position = polygon.position
	add_child(point_holder)
	point_holder.owner = get_parent()
	for p in points:
		var point = point_res.instantiate()
		point.position = p
		point_holder.add_child(point, true)
		point.owner = get_parent()
	generating = false

func clear():
	points = []
	if point_holder != null:
		remove_child(point_holder)
		point_holder.free()
		point_holder = null

func generate():
	if !generating:
		if _is_valid():
			generating = true
			clear()
			polygon = get_polygons()[0]
			gen_thread = Thread.new()
			gen_thread.start(_generate_thread)
		else:
			print_rich("[color=yellow]Cannot generate; Check warnings.[/color]")

func _generate_thread():
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

func get_polygon_rect(polygon: Polygon2D) -> Rect2:
	var min: Vector2 = Vector2(INF, INF)
	var max: Vector2 = Vector2(-INF, -INF)
	for point in polygon.polygon:
		if point.x < min.x:
			min.x = point.x
		if point.x > max.x:
			max.x = point.x
		if point.y < min.y:
			min.y = point.y
		if point.y > max.y:
			max.y = point.y

	return Rect2(min, max - min)

func get_polygons() -> Array:
	return find_children("*", "Polygon2D", false)

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
