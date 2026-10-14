// Relâmpagos brancos no fundo do Ghostty (modo Übermensch do BonVel OS).
// Formato Shadertoy: iChannel0 é o conteúdo do terminal, iTime o tempo em segundos.
// Ativado pelo comando ubermensch através de custom-shader no Ghostty.

float hash(float n) { return fract(sin(n) * 43758.5453123); }

float ruido(float x) {
    float i = floor(x), f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i + 1.0), f) * 2.0 - 1.0;
}

float fbm(float x) {
    float v = 0.0, a = 0.5;
    for (int i = 0; i < 5; i++) {
        v += a * ruido(x);
        x *= 2.13;
        a *= 0.5;
    }
    return v;
}

// Posição horizontal de um raio na altura y (y = 0 no topo)
float caminho(float y, float semente, float x0, float y0, float inclinacao, float amp) {
    return x0 + inclinacao * (y - y0) + amp * fbm(y * 7.0 + semente * 13.7);
}

// Brilho de um raio que desce de y0 até y1, com o fim a afinar
float raio(vec2 p, float semente, float x0, float y0, float y1, float inclinacao, float amp) {
    if (p.y < y0 || p.y > y1) return 0.0;
    float x = caminho(p.y, semente, x0, y0, inclinacao, amp);
    float x2 = caminho(p.y + 0.01, semente, x0, y0, inclinacao, amp);
    float declive = min(abs(x2 - x) / 0.01, 2.0);
    float d = abs(p.x - x) / sqrt(1.0 + declive * declive) * iResolution.y;
    float fim = smoothstep(y1, y1 - 0.15 * (y1 - y0) - 0.02, p.y);
    float nucleo = smoothstep(1.6, 0.0, d);
    // O brilho largo segue uma versão suave do caminho, para não fazer riscos
    float xs = x0 + inclinacao * (p.y - y0) + amp * 0.5 * ruido(p.y * 7.0 + semente * 13.7);
    float ds = abs(p.x - xs) * iResolution.y;
    float halo = exp(-d / 8.0) * 0.4 + exp(-ds / 60.0) * 0.08;
    return (nucleo + halo) * fim;
}

// Uma camada de trovoada: um relâmpago (com ramos) por ciclo, num momento aleatório
float trovoada(vec2 p, float largura, float periodo, float desvio) {
    float t = iTime + desvio;
    float ciclo = floor(t / periodo);
    float s = ciclo * 1.618 + desvio * 7.31;
    float dt = t - ciclo * periodo - hash(s) * periodo * 0.45;
    if (dt < 0.0) return 0.0;

    // Clarão principal, segundo golpe e tremura
    float env = exp(-dt * 9.0) + 0.8 * step(0.11, dt) * exp(-(dt - 0.11) * 6.0);
    env *= 0.8 + 0.2 * sin(dt * 95.0);
    if (env < 0.01) return 0.0;

    float x0 = (0.08 + 0.84 * hash(s + 2.7)) * largura;
    float y1 = 0.55 + 0.45 * hash(s + 3.1);
    float inclinacao = (hash(s + 4.3) - 0.5) * 0.5;
    float amp = 0.06 + 0.05 * hash(s + 5.9);

    float brilho = raio(p, s, x0, -0.02, y1, inclinacao, amp);

    for (int i = 0; i < 3; i++) {
        float r = s + float(i) * 11.3;
        float by0 = mix(0.08, y1 * 0.8, hash(r + 6.1));
        float bx0 = caminho(by0, s, x0, -0.02, inclinacao, amp);
        float lado = hash(r + 7.7) < 0.5 ? -1.0 : 1.0;
        float by1 = by0 + 0.1 + 0.25 * hash(r + 8.3);
        brilho += 0.55 * raio(p, r, bx0, by0, by1, lado * (0.4 + 0.8 * hash(r + 9.1)), 0.03);
    }

    // O céu inteiro acende um pouco a cada relâmpago
    return (brilho + 0.035) * env;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 terminal = texture(iChannel0, uv);

    vec2 p = vec2(fragCoord.x, iResolution.y - fragCoord.y) / iResolution.y;
    float largura = iResolution.x / iResolution.y;

    // Duas camadas com períodos diferentes: nunca param e não se repetem de forma óbvia
    float luz = trovoada(p, largura, 1.9, 0.0) + trovoada(p, largura, 3.1, 41.0);
    luz = min(luz, 0.9);

    // O texto fica por cima: o relâmpago só ilumina o que é escuro
    float lum = dot(terminal.rgb, vec3(0.299, 0.587, 0.114));
    fragColor = vec4(terminal.rgb + vec3(luz) * (1.0 - lum), max(terminal.a, luz));
}
