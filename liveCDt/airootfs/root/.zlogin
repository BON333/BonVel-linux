# fix for screen readers
if grep -Fqa 'accessibility=' /proc/cmdline &> /dev/null; then
    setopt SINGLE_LINE_ZLE
fi

~/.automated_script.sh

# BonVel: arranca o Hyprland no tty1 (exceto no modo de acessibilidade com leitor de ecrã)
if [[ -z $WAYLAND_DISPLAY && $(tty) == /dev/tty1 ]] && ! grep -Fqa 'accessibility=' /proc/cmdline &> /dev/null; then
    exec Hyprland --i-am-really-stupid
fi
