shader_type canvas_item;

uniform vec4 color : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float dist_from_center = distance(vec2(0.5), UV);
	if(dist_from_center <= 0.5) {
		COLOR = color;
	} else {
		COLOR = vec4(0.0);
	}
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
