# fix for screen readers
if grep -Fqa 'accessibility=' /proc/cmdline &> /dev/null; then
    setopt SINGLE_LINE_ZLE
fi

~/.automated_script.sh

# BonVel: o root recebe uma cópia das configurações (um link sujaria o /etc/skel que o post_install copia)
[[ -d ~/.config/hypr ]] || cp -a /etc/skel/.config ~/

# BonVel: arranca o Hyprland no tty1 (exceto no modo de acessibilidade com leitor de ecrã)
if [[ -z $WAYLAND_DISPLAY && $(tty) == /dev/tty1 ]] && ! grep -Fqa 'accessibility=' /proc/cmdline &> /dev/null; then
    exec start-hyprland -- --i-am-really-stupid
fi
