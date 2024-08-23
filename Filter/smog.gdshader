shader_type canvas_item;

uniform float smog : hint_range(0.0, 50.0) = 0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    float alpha = clamp(smog / 100.0, 0.0, 1.0);
    COLOR = vec4(0.1, 0.1, 0.1, alpha); // Dunkelgrauer Smog
}

void light() {
    float light_intensity = dot(LIGHT.rgb, vec3(0.333)); // Mittelwert der Lichtfarbe
    vec3 light_color = LIGHT.rgb * light_intensity * 0.5; // Berechnet die Lichtfarbe
    LIGHT.rgb = light_color;
}
