class_name PoissonDiskSampler

const SQRT_TWO = sqrt(2)

static func generate_points(bounds: Rect2, min_dist: float, attempts: int, _is_valid_point: Callable) -> Array[Vector2]:
    var real_cell_size: Vector2 = get_real_cell_size(min_dist, bounds)
    
    var grid: Dictionary = {}

    var points: Array[Vector2] = []
    var active_points: Array[int] = []

    var start_point: Vector2 = Vector2(0.0, 0.0)
    while true:
        start_point = get_random_start_point(bounds)
        if _is_valid_point.call(start_point):
            break
    active_points.append(insert_sample(grid, points, start_point, real_cell_size))

    while !active_points.is_empty():
        var rand_index: int = randi() % active_points.size()
        var active_point: Vector2 = points[active_points[rand_index]]
        var point_found = false
        for _k in attempts:
            var rand_angle: float = 2.0 * PI * randf()
            var sample_point: Vector2 = active_point + Vector2(cos(rand_angle), sin(rand_angle)) * lerpf(min_dist, 2 * min_dist, randf())
            if _is_valid_point.call(sample_point):
                var sample_cell_index: Vector2i = get_grid_cell_index(bounds, sample_point, real_cell_size)
                #if !is_point_nearby(sample_point, points, min_dist):
                if !is_point_nearby_grid(bounds, sample_point, points, grid, min_dist, real_cell_size):
                    active_points.append(insert_sample(grid, points, sample_point, sample_cell_index))
                    point_found = true
        if !point_found:
            active_points.remove_at(rand_index)
    return points

static func get_real_cell_size(min_dist: float, bounds: Rect2) -> Vector2:
    var cell_size: float = min_dist / SQRT_TWO
    var grid_size: Vector2 = Vector2(
        max(floor(bounds.size.x / cell_size), 1.0),
        max(floor(bounds.size.y / cell_size), 1.0))
    return bounds.size / grid_size

static func get_random_start_point(bounds: Rect2) -> Vector2:
    return Vector2(
            lerpf(bounds.position.x, bounds.end.x, randf()),
            lerpf(bounds.position.y, bounds.end.y, randf()))

static func insert_sample(grid: Dictionary, points: Array[Vector2], point: Vector2, cell_index: Vector2i) -> int:
    points.append(point)
    var new_index: int = points.size() - 1
    grid[cell_index] = new_index
    return new_index

static func get_grid_cell_index(bounds: Rect2, point: Vector2, cell_size: Vector2) -> Vector2i:
    var adjusted_point = point - (bounds.end - bounds.size / 2.0)
    return Vector2i(floor(adjusted_point / cell_size))

static func is_point_nearby(point: Vector2, points: Array[Vector2], min_dist: float):
    var min_dist_squared: float = min_dist * min_dist
    for temp_point in points:
        if point.distance_squared_to(temp_point) < min_dist_squared:
            return true
    return false

static func is_point_nearby_grid(bounds: Rect2, point: Vector2, points: Array[Vector2], grid: Dictionary, min_dist: float, cell_size: Vector2):
    var center_index = get_grid_cell_index(bounds, point, cell_size)
    var nearby_index =  [
        center_index + Vector2i.UP,
        center_index + Vector2i.UP + Vector2i.RIGHT,
        center_index + Vector2i.RIGHT,
        center_index + Vector2i.RIGHT + Vector2i.DOWN,
        center_index + Vector2i.DOWN,
        center_index + Vector2i.DOWN + Vector2i.LEFT,
        center_index + Vector2i.LEFT,
        center_index + Vector2i.LEFT + Vector2i.UP
    ]
    for cell_index in nearby_index:
        if is_near_grid_point(cell_index, point, points, grid, min_dist):
            return true
    return false

static func is_near_grid_point(nearby_index: Vector2i, point: Vector2, points: Array[Vector2], grid: Dictionary, min_dist: float):
    return grid.has(nearby_index) && point.distance_squared_to(points[grid[nearby_index]]) < min_dist * min_dist