# Configure the terminal for screen readers when requested at boot.
if grep -Fqa 'accessibility=' /proc/cmdline &>/dev/null; then
    setopt SINGLE_LINE_ZLE
fi

if ! sudo /usr/local/bin/bonvel-live-set-password; then
    print -u2 'Não foi possível configurar a palavra-passe; corre novamente sudo /usr/local/bin/bonvel-live-set-password.'
    return 1
fi

if [[ $(tty) == /dev/tty1 ]]; then
    if grep -Fqa 'script=' /proc/cmdline; then
        sudo /root/.automated_script.sh
    fi
fi

if [[ -z $WAYLAND_DISPLAY && $(tty) == /dev/tty1 ]] && ! grep -Fqa 'accessibility=' /proc/cmdline &>/dev/null; then
    exec start-hyprland
fi
