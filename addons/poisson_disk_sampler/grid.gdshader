shader_type canvas_item;

uniform vec2 offset = vec2(0.0);
uniform vec2 cell_size = vec2(1.0);

varying vec2 local_vertex;

void vertex() {
	local_vertex = VERTEX;
}

void fragment() {
	vec2 polygon_vertex = local_vertex - offset;
	if(distance(polygon_vertex, vec2(0.0)) <= 5.0){
		COLOR = vec4(1.0, 0.0, 0.0, 1.0);
	} else if(mod(polygon_vertex.x, cell_size.x) <= 2.0 || mod(polygon_vertex.y, cell_size.y) <= 2.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	}
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
