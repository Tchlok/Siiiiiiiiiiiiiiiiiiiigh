shader_type canvas_item;
uniform vec4 cTop : source_color;
uniform vec4 cBottom : source_color;


void fragment() {
	COLOR = mix(cTop, cBottom, pow(UV.y,1.6f));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
