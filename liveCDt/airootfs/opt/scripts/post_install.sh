#!/bin/bash
# O archinstall executa este script DENTRO do sistema instalado (/mnt)

echo "==> A copiar ficheiros e configurações do BonVel OS..."

# 1. Copiar os teus scripts e mídias para o novo sistema
mkdir -p /opt/scripts
cp -r /run/archiso/bootmnt/opt/scripts/* /opt/scripts/ 2>/dev/null || cp -r /opt/scripts/* /opt/scripts/

# 2. Copiar as tuas configurações (dotfiles/Hyprland) do root/skel para o novo sistema
cp -r /etc/skel/. /etc/skel/ 2>/dev/null
cp -r /root/. /root/ 2>/dev/null

# 3. Dar permissões de execução
chmod +x /opt/scripts/*.sh 2>/dev/null

echo "==> BonVel OS configurado com sucesso no disco!"
