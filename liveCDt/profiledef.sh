#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="bonvel-os"
iso_label="BV_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Hussein <https://github.com/BON333> & Mente-MiIionaria <https://github.com/Mente-MiIionaria>"
iso_application="BonVel OS Live/Rescue DVD"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.grub')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86,arm64' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/usr/local/bin/bonvel-tema"]="0:0:755"
  ["/usr/local/bin/bonvel-atalhos"]="0:0:755"
  ["/usr/local/bin/ubermensch"]="0:0:755"
  ["/usr/local/bin/bonvel-boas-vindas"]="0:0:755"
  # O mkarchiso não preserva permissões: cada script tem de estar aqui para ser executável
  ["/opt/scripts"]="0:0:755"
  ["/opt/scripts/scriptT"]="0:0:755"
  ["/opt/scripts/hacked.sh"]="0:0:755"
  ["/opt/scripts/cktor.sh"]="0:0:755"
  ["/opt/scripts/fp.sh"]="0:0:755"
  ["/opt/scripts/IRN.sh"]="0:0:755"
  ["/opt/scripts/post_install.sh"]="0:0:755"
  ["/opt/scripts/bonvel-instalar.sh"]="0:0:755"
)
