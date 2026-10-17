#!/bin/bash
# Instala o BonVel OS no disco num só comando: rede, archinstall e post_install.
# Corre no sistema ao vivo (ISO), como root.
# Uso: bonvel-instalar [--sem-archinstall]
#   --sem-archinstall  o archinstall já correu (por exemplo, reiniciaste antes do post_install):
#                      monta o sistema instalado e só instala o BonVel

set -euo pipefail

azul=$'\e[38;2;137;180;250m'; rosa=$'\e[35m'; vermelho=$'\e[31m'; normal=$'\e[0m'
passo() { printf '\n%s==> %s%s\n' "$azul" "$*" "$normal"; }
erro() { printf '%sErro: %s%s\n' "$vermelho" "$*" "$normal" >&2; exit 1; }
sim() { local r; read -rp "$1 [S/n] " r; [[ ! $r =~ ^[nN] ]]; }

SEM_ARCHINSTALL=0
case "${1:-}" in
    --sem-archinstall) SEM_ARCHINSTALL=1 ;;
    "") ;;
    *) erro "opção desconhecida: $1 (uso: bonvel-instalar [--sem-archinstall])" ;;
esac

[ "$(id -u)" -eq 0 ] || erro "corre como root (no sistema ao vivo já és root)."
[ -d /run/archiso ] || erro "isto só funciona no sistema ao vivo do BonVel."

# 1. Rede: o archinstall e o post_install descarregam os pacotes
tem_rede() { curl -fsI --max-time 5 https://archlinux.org >/dev/null 2>&1; }

passo "1/3 Ligação à internet"
until tem_rede; do
    echo "Sem internet. O cabo de rede liga-se sozinho; para Wi-Fi usa o iwctl:"
    echo "  ${rosa}station wlan0 get-networks${normal}, depois ${rosa}station wlan0 connect NOME${normal} e ${rosa}exit${normal}"
    sim "Abrir o iwctl?" || erro "a instalação precisa de internet."
    iwctl || true
done
echo "Ligado."

# 2. archinstall: disco, utilizador, idioma, etc.
if [ "$SEM_ARCHINSTALL" -eq 0 ]; then
    passo "2/3 archinstall"
    cat <<EOF
Vai abrir o archinstall. Para o BonVel funcionar bem:
  - ${rosa}Profile${normal}: Minimal. O ambiente gráfico do BonVel é instalado no passo seguinte.
  - ${rosa}Authentication${normal}: cria um utilizador com sudo (superuser). É com ele que entras no tty1.
  - ${rosa}Network configuration${normal}: "Copy ISO network configuration to installation".
  - No fim escolhe ${rosa}Exit archinstall${normal}. NÃO escolhas "Reboot system": falta instalar o BonVel.
EOF
    read -rp "Enter para abrir o archinstall... "
    archinstall --mountpoint /mnt || erro "o archinstall falhou. Corre bonvel-instalar outra vez."
else
    passo "2/3 archinstall (saltado)"
fi

# 3. Encontrar o sistema instalado e pôr-lhe o BonVel
# O archinstall deixa-o montado em /mnt; se já não estiver (reiniciaste), monta-o a partir do disco.
montado() { mountpoint -q /mnt && [ -f /mnt/etc/fstab ]; }

# Raízes candidatas: partições Linux com /etc/fstab (no btrfs do archinstall, no subvolume @).
# Escreve "dispositivo subvolume" por linha, a instalação mais recente primeiro.
candidatos() {
    local tmp dev fs sub
    tmp=$(mktemp -d)
    lsblk -rnpo NAME,FSTYPE | while read -r dev fs; do
        case "$fs" in ext4|btrfs|xfs|f2fs) ;; *) continue ;; esac
        mount -o ro "$dev" "$tmp" 2>/dev/null || continue
        for sub in "" @; do
            if [ -f "$tmp/${sub:+$sub/}etc/fstab" ]; then
                echo "$(stat -c %Y "$tmp/${sub:+$sub/}etc/fstab") $dev ${sub:--}"
                break
            fi
        done
        umount "$tmp"
    done | sort -rn | cut -d' ' -f2-
    rmdir "$tmp"
}

montar_alvo() {
    local dev sub alvo
    mapfile -t lista < <(candidatos)
    [ "${#lista[@]}" -gt 0 ] || erro "não encontrei o sistema instalado. Se o disco é encriptado, abre-o (cryptsetup open), monta a raiz em /mnt e corre post_install."
    for alvo in "${lista[@]}"; do
        read -r dev sub <<<"$alvo"
        if sim "Instalar o BonVel no sistema em ${rosa}$dev${normal}?"; then
            if [ "$sub" = - ]; then mount "$dev" /mnt; else mount -o "subvol=$sub" "$dev" /mnt; fi
            # O resto do fstab (/home, /boot...), com /mnt à frente; a swap e a raiz ficam de fora
            findmnt --fstab --tab-file /mnt/etc/fstab -rn -o TARGET | while read -r ponto; do
                case "$ponto" in /|none|swap) continue ;; esac
                mount --fstab /mnt/etc/fstab --target-prefix /mnt "$ponto"
            done
            return
        fi
    done
    erro "nenhum sistema escolhido. Monta a raiz em /mnt e corre post_install."
}

passo "3/3 BonVel OS"
if montado; then
    echo "Sistema instalado encontrado em /mnt."
else
    montar_alvo
fi
/opt/scripts/post_install.sh /mnt

passo "Instalação terminada"
echo "Depois de reiniciar, tira a pen e entra com o teu utilizador no tty1: o Hyprland arranca sozinho."
if sim "Reiniciar agora?"; then
    sync
    umount -R /mnt || true
    reboot
else
    echo "Quando quiseres: ${rosa}umount -R /mnt && reboot${normal}"
fi
