#!/bin/bash
# Corre isto no sistema ao vivo (ISO), DEPOIS do archinstall acabar e ANTES de reiniciar.
# Copia os ficheiros do BonVel OS da ISO para o sistema instalado.
# Uso: post_install.sh [ponto_de_montagem]   (por omissão: /mnt)

set -e

TARGET="${1:-/mnt}"

if [ ! -d "$TARGET/etc" ]; then
    echo "Erro: $TARGET não parece ser um sistema instalado (falta $TARGET/etc)."
    echo "Monta primeiro a partição raiz do disco em $TARGET."
    exit 1
fi

echo "==> A copiar ficheiros e configurações do BonVel OS para $TARGET..."

# 1. Scripts e mídias
mkdir -p "$TARGET/opt/scripts"
cp -a /opt/scripts/. "$TARGET/opt/scripts/"

# 2. Configurações (Hyprland/Omarchy) para os utilizadores novos
cp -a /etc/skel/. "$TARGET/etc/skel/"

# 3. Homepage e política do Firefox
mkdir -p "$TARGET/usr/share/bonvel" "$TARGET/usr/lib/firefox/distribution"
cp -a /usr/share/bonvel/. "$TARGET/usr/share/bonvel/"
cp -a /usr/lib/firefox/distribution/policies.json "$TARGET/usr/lib/firefox/distribution/"

# 4. Utilizadores já criados pelo archinstall recebem as configurações também
for home in "$TARGET"/home/*/; do
    [ -d "$home" ] || continue
    user="$(basename "$home")"
    cp -a --no-clobber /etc/skel/. "$home"
    arch-chroot "$TARGET" chown -R "$user:" "/home/$user"
done

echo "==> BonVel OS configurado com sucesso no disco!"
