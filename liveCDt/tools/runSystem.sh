#!/bin/bash
# Testa a ISO do BonVel OS no QEMU (corre no PC de desenvolvimento, não faz parte da ISO).
# Uso: runSystem.sh [caminho/para/a.iso]   (por omissão: a ISO mais recente em ~/iso_out)

ISO="${1:-$(ls -t ~/iso_out/*.iso 2>/dev/null | head -1)}"

if [ ! -f "$ISO" ]; then
    echo "Nenhuma ISO encontrada. Constrói primeiro com: sudo mkarchiso -v -w ~/iso_work -o ~/iso_out ~/liveCDt"
    exit 1
fi

qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -smp 4 \
  -cpu host \
  -bios /usr/share/edk2/x64/OVMF.4m.fd \
  -vga virtio \
  -display gtk,gl=on \
  -cdrom "$ISO"
