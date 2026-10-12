#!/bin/bash
# Testa os menus de arranque da ISO do BonVel OS no QEMU (sem janela, não precisa de root).
# Tira capturas do menu em BIOS (syslinux) e em UEFI (GRUB) e confirma que a entrada
# por omissão do GRUB arranca o sistema até ao Hyprland.
# Uso: tools/test-arranque.sh [a.iso] [pasta_de_resultados]

ISO="${1:-$(ls -t ~/iso_out/*.iso 2>/dev/null | head -1)}"
OUT="${2:-$(mktemp -d /tmp/bonvel-arranque-XXXX)}"
OVMF=/usr/share/edk2/x64/OVMF.4m.fd
mkdir -p "$OUT"
echo "ISO: $ISO"

captura() {  # captura <socket> <nome>
    echo "screendump $OUT/$2.ppm" | socat - "unix-connect:$1" >/dev/null
    sleep 1
    magick "$OUT/$2.ppm" "$OUT/$2.png" && rm -f "$OUT/$2.ppm"
    echo "captura: $OUT/$2.png"
}

arrancar() {  # arrancar <modo> <segundos até à captura do menu> [segundos até à captura do sistema]
    local modo=$1 sock
    sock="$(mktemp -u /tmp/bv-XXXX.sock)"
    local firmware=()
    [ "$modo" = uefi ] && firmware=(-bios "$OVMF")
    qemu-system-x86_64 -enable-kvm -machine q35 -m 4G -smp 4 -cpu host "${firmware[@]}" \
        -cdrom "$ISO" -vga virtio -display none -monitor "unix:$sock,server,nowait" 2>/dev/null &
    local pid=$!
    sleep "$2"
    captura "$sock" "menu-$modo"
    if [ -n "$3" ]; then
        sleep "$3"
        captura "$sock" "sistema-$modo"
    fi
    kill "$pid"
    wait "$pid" 2>/dev/null
    rm -f "$sock"
}

arrancar bios 8
arrancar uefi 8 90
echo "Resultados: $OUT"
