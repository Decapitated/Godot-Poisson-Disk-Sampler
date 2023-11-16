# Poisson Disk Sampler
A "Fast Poisson Disk Sampling" Godot plugin

![Poisson Animated Fill](https://github.com/Decapitated/Godot-Poisson-Disk-Sampler/blob/main/docs/PoissonFill-Rainbow.gif?raw=true)

I created this after trying [udit's implementation](https://github.com/udit/poisson-disc-sampling). For whatever reason it didn't work for me, and wanted to try doing it myself. This one aims to improve by abstracting the way points are validated, as well as possibly adding more dimensions - as stated in Robert's paper.

## Usage
How to generate points for different shapes:
### Polygon
```GDScript
var poisson_points = PoissonDiskSampler.generate_points(
        get_polygon_rect(polygon), # Polygon bounding rect.
        min_dist,
        max_attempts,
        _is_point_in_polygon.bind(polygon))

func _is_point_in_polygon(point: Vector2, polygon: Polygon2D) -> bool:
    return Geometry2D.is_point_in_polygon(point, polygon.polygon)
```
### Circle
```GDScript
var circle_rect = Rect2(Vector2(0.0, 0.0), Vector2(1000.0, 1000.0))
var poisson_points = PoissonDiskSampler.generate_points(
        circle_rect,
        min_dist,
        max_attempts,
        _is_point_in_circle.bind(circle_rect))

func _is_point_in_circle(point: Vector2, rect: Rect2) -> bool:
    var radius = rect.size.x / 2.0
    return point.distance_squared_to(rect.size / 2.0) <= radius * radius
```
## To-Do
* Right now for each point, we loop over all added points to check if it is valid. You're supposed to only check nearby points. Need to get that working.

## Citations
* [Fast Poisson Disk Sampling in Arbitrary Dimensions](https://www.cs.ubc.ca/~rbridson/docs/bridson-siggraph07-poissondisk.pdf)
