# BonVel OS: arranca o Hyprland ao entrar no tty1 no sistema instalado.
# A ISO ao vivo usa o .zlogin do utilizador bonvel para preparar a sessão.
if [ ! -d /run/archiso ] && [ "$(id -u)" -ne 0 ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = /dev/tty1 ] && command -v start-hyprland >/dev/null; then
    exec start-hyprland
fi
