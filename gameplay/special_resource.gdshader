shader_type canvas_item;

uniform float speed = 1.0;
uniform float intensity = 0.5;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    float hue = fract(TIME * speed + UV.x);
    vec3 rainbow = hsv2rgb(vec3(hue, 1.0, 1.0));

    tex.rgb = mix(tex.rgb, rainbow, intensity);

    COLOR = tex;
}
