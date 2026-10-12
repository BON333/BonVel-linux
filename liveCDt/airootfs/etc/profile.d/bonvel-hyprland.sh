# BonVel OS: arranca o Hyprland ao entrar no tty1 (utilizadores normais no sistema instalado).
# O root da ISO ao vivo arranca-o pelo /root/.zlogin.
if [ "$(id -u)" -ne 0 ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = /dev/tty1 ] && command -v start-hyprland >/dev/null; then
    exec start-hyprland
fi
