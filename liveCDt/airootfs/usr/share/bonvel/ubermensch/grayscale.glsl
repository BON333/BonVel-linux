#version 300 es
// Modo Übermensch: ecrã a preto e branco com um pouco mais de contraste
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 c = texture(tex, v_texcoord);
    float y = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
    y = clamp((y - 0.5) * 1.15 + 0.5, 0.0, 1.0);
    fragColor = vec4(vec3(y), c.a);
}
