# Shaders do Hyprland

Shaders de ecrã retirados do projeto [Aether](https://github.com/bjarneo/aether)
(licença MIT, Bjarne Øverli), da última versão antes de serem removidos
(commit a163b16^). O `#version` foi movido para a primeira linha, como o
OpenGL ES exige.

Aplicar um: `hyprctl keyword decoration:screen_shader ~/.config/hypr/shaders/noir.glsl`
Remover: `hyprctl keyword decoration:screen_shader "[[EMPTY]]"`

O `common.glsl` não é um shader: são funções auxiliares para copiar para outros.
