#!/bin/bash
# Constrói a ISO do BonVel OS.
# Uso: tools/build.sh   (a ISO fica em ~/iso_out)

set -e

PERFIL="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$HOME/iso_work"
OUT="$HOME/iso_out"

# Os pacotes que o post_install instala no disco também têm de estar na ISO
LISTA="$PERFIL/airootfs/usr/share/bonvel/pacotes-desktop.txt"
for p in $(grep -vE '^\s*(#|$)' "$LISTA"); do
    if ! grep -qx "$p" "$PERFIL/packages.x86_64"; then
        echo "Aviso: '$p' está em pacotes-desktop.txt mas não em packages.x86_64"
    fi
done

# O repo BlackArch exige assinaturas: a chave tem de estar assinada localmente
CHAVE=F9A6E68A711354D84A9B91637533BAFE69A25079
if ! pacman-key --list-sigs "$CHAVE" 2>/dev/null | grep -q 'Pacman Keyring Master Key'; then
    echo "==> A importar e assinar a chave do BlackArch..."
    sudo pacman-key --recv-keys "$CHAVE"
    sudo pacman-key --lsign-key "$CHAVE"
fi

mkdir -p "$OUT"
# Até 3 tentativas (os mirrors às vezes param a meio). Uma pasta de trabalho antiga faria o
# mkarchiso saltar passos e usar ficheiros velhos, por isso é sempre limpa antes.
# O mkarchiso pergunta ao pacman (fornecedores, confirmação): responde sempre o valor por omissão.
for tentativa in 1 2 3; do
    sudo rm -rf "$WORK"
    echo "==> mkarchiso (tentativa $tentativa)"
    if yes "" | sudo mkarchiso -v -w "$WORK" -o "$OUT" "$PERFIL"; then
        break
    fi
    [ "$tentativa" -lt 3 ] || exit 1
    sleep 30
done

echo "==> ISO pronta:"
ls -t "$OUT"/*.iso | head -1
echo "Para testar: $PERFIL/tools/runSystem.sh"
