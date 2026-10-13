#version 300 es
// NEGATIVE - Photo negative inversion
// Use with: hyprshade on negative

precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;
out vec4 fragColor;

void main() {
    vec4 color = texture(tex, v_texcoord);

    // Invert colors
    color.rgb = vec3(1.0) - color.rgb;

    fragColor = color;
}
