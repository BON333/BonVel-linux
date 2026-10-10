#!/bin/bash

qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -smp 4 \
  -cpu host \
  -bios /usr/share/edk2/x64/OVMF.4m.fd \
  -vga virtio \
  -display gtk,gl=on \
  -cdrom ~/iso_out/BonVel\ OS-2026.09.19-x86_64.iso

