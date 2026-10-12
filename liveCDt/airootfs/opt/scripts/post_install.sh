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

echo "==> A instalar os pacotes do BonVel OS em $TARGET (precisa de internet)..."
grep -vE '^\s*(#|$)' /usr/share/bonvel/pacotes-desktop.txt \
    | arch-chroot "$TARGET" pacman -S --needed --noconfirm -

echo "==> A copiar ficheiros e configurações do BonVel OS para $TARGET..."

# 1. Scripts, mídias e comandos do BonVel
mkdir -p "$TARGET/opt/scripts"
cp -a /opt/scripts/. "$TARGET/opt/scripts/"
chmod 755 "$TARGET"/opt/scripts/*.sh "$TARGET/opt/scripts/scriptT"
cp -a /usr/local/bin/bonvel-tema /usr/local/bin/bonvel-atalhos "$TARGET/usr/local/bin/"
chmod 755 "$TARGET/usr/local/bin/bonvel-tema" "$TARGET/usr/local/bin/bonvel-atalhos"
for s in hacked cktor fp IRN; do
    ln -sfn "/opt/scripts/$s.sh" "$TARGET/usr/local/bin/$s"
done
ln -sfn /opt/scripts/scriptT "$TARGET/usr/local/bin/scriptT"

# Hyprland arranca sozinho ao entrar no tty1
cp -a /etc/profile.d/bonvel-hyprland.sh "$TARGET/etc/profile.d/"

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
    cp -a --update=none /etc/skel/. "$home"
    arch-chroot "$TARGET" chown -R "$user:" "/home/$user"
done

# 5. Repositório BlackArch (opcional: se falhar, o resto da instalação fica feito)
adicionar_blackarch() {
    local chave=F9A6E68A711354D84A9B91637533BAFE69A25079
    # O arch-chroot monta um /tmp vazio, por isso a chave passa pelo /root do disco
    pacman-key --export "$chave" > "$TARGET/root/blackarch.asc" &&
    arch-chroot "$TARGET" pacman-key --add /root/blackarch.asc &&
    arch-chroot "$TARGET" pacman-key --lsign-key "$chave" || return 1
    rm -f "$TARGET/root/blackarch.asc"
    if ! grep -q '^\[blackarch\]' "$TARGET/etc/pacman.conf"; then
        printf '\n[blackarch]\nSigLevel = Required DatabaseOptional\nServer = https://blackarch.org/blackarch/$repo/os/$arch\n' >> "$TARGET/etc/pacman.conf"
    fi
    arch-chroot "$TARGET" pacman -Sy --needed --noconfirm blackarch-keyring
}
echo "==> A adicionar o repositório BlackArch a $TARGET..."
if ! adicionar_blackarch; then
    rm -f "$TARGET/root/blackarch.asc"
    echo "Aviso: não foi possível configurar o BlackArch. O BonVel ficou instalado; tenta mais tarde com rede."
fi

echo "==> BonVel OS configurado com sucesso no disco!"
