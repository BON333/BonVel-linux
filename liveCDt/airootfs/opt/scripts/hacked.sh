#!/bin/bash
# hacked.sh - só visual, nada de merda destrutiva

# Procura a imagem ao lado do script, seja qual for a pasta de onde é chamado
IMG="$(dirname "$(readlink -f "$0")")/hacked.png"   # ou .gif se quiseres animado

# Verifica se a imagem existe
if [ ! -f "$IMG" ]; then
    echo "Puta, mete a imagem $IMG na pasta primeiro."
    exit 1
fi

# Tenta abrir em fullscreen com feh (melhor opção)
if command -v feh >/dev/null 2>&1; then
    feh --fullscreen --auto-zoom --hide-pointer "$IMG" &
    FEH_PID=$!
elif command -v mpv >/dev/null 2>&1; then
    mpv --fullscreen --loop=inf --no-audio "$IMG" &
    FEH_PID=$!
else
    # Fallback merda
    xdg-open "$IMG" &
    FEH_PID=$!
fi

# Mensagem no terminal estilo hacker de merda
clear
echo -e "\e[32m"
for i in {1..30}; do
    echo "HACKEADO  HACKEADO  HACKEADO  HACKEADO"
    sleep 0.15
done
echo -e "\e[0m"

# Espera um pouco e mata a imagem
sleep 2
kill $FEH_PID 2>/dev/null
clear
echo "Acabou a piada, puta."
