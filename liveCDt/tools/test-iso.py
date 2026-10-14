#!/usr/bin/env python3
"""Teste automático da ISO do BonVel OS no QEMU (sem janela, não precisa de root).

Arranca a ISO com o kernel e o initramfs extraídos dela, para poder pôr a consola na
porta série. Depois entra como root pela porta série, corre as verificações e tira
capturas de ecrã do tty1, onde o Hyprland deve arrancar.

Uso: tools/test-iso.py [a.iso] [pasta_de_resultados]
Com BONVEL_INSTALL=1 também instala num disco virtual (pacstrap + post_install)
e verifica o sistema instalado. Demora bastante e descarrega vários GB.
"""
import glob
import os
import re
import socket
import subprocess
import sys
import tempfile
import time

ISO = sys.argv[1] if len(sys.argv) > 1 else max(glob.glob(os.path.expanduser("~/iso_out/*.iso")), key=os.path.getmtime)
OUT = sys.argv[2] if len(sys.argv) > 2 else tempfile.mkdtemp(prefix="bonvel-test-")
os.makedirs(OUT, exist_ok=True)
print(f"ISO: {ISO}\nResultados: {OUT}")


def extrair(caminho_iso, destino):
    subprocess.run(["osirrox", "-indev", ISO, "-extract", caminho_iso, destino],
                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


# Kernel, initramfs e o UUID da ISO (está no menu do syslinux já processado)
extrair("/arch/boot/x86_64/vmlinuz-linux", f"{OUT}/vmlinuz")
extrair("/arch/boot/x86_64/initramfs-linux.img", f"{OUT}/initramfs.img")
extrair("/boot/syslinux/archiso_sys-linux.cfg", f"{OUT}/sys-linux.cfg")
cfg = open(f"{OUT}/sys-linux.cfg").read()
# Os mesmos parâmetros da primeira entrada do menu de arranque
params = re.search(r"^APPEND (.+)$", cfg, re.M).group(1)

# Os sockets Unix têm limite de 108 bytes no caminho: ficam numa pasta curta
SOCKS = tempfile.mkdtemp(prefix="bv-", dir="/tmp")
INSTALAR = os.environ.get("BONVEL_INSTALL") == "1"
SO_INSTALAR = os.environ.get("BONVEL_SO_INSTALAR") == "1"  # salta os testes do sistema ao vivo
# Usa o post_install.sh do repositório em vez do que vem na ISO (testar sem recompilar)
INJETAR = os.environ.get("BONVEL_INJETAR") == "1"
SCRIPTS_LOCAIS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "airootfs", "opt", "scripts")
disco = []
if INSTALAR:
    subprocess.run(["qemu-img", "create", "-f", "qcow2", f"{OUT}/disco.qcow2", "30G"],
                   check=True, stdout=subprocess.DEVNULL)
    disco = ["-drive", f"file={OUT}/disco.qcow2,if=virtio,format=qcow2",
             # Cache de pacotes do PC, só de leitura: evita descarregar GB pela rede lenta do QEMU
             "-virtfs", "local,path=/var/cache/pacman/pkg,mount_tag=hostcache,security_model=none,readonly=on"]
    if INJETAR:
        disco += ["-virtfs", f"local,path={SCRIPTS_LOCAIS},mount_tag=bvscripts,security_model=none,readonly=on"]
# Mirror do PC que constrói a ISO (a cache local corresponde às versões dele)
MIRROR = next((l.split("=", 1)[1].strip() for l in open("/etc/pacman.d/mirrorlist")
               if l.startswith("Server")), "https://geo.mirror.pkgbuild.com/$repo/os/$arch")
serial_sock = f"{SOCKS}/serial"
mon_sock = f"{SOCKS}/monitor"
qemu = subprocess.Popen([
    "qemu-system-x86_64", "-enable-kvm", "-machine", "q35", "-m", os.environ.get("BONVEL_RAM", "4G"), "-smp", "4", "-cpu", "host",
    "-kernel", f"{OUT}/vmlinuz", "-initrd", f"{OUT}/initramfs.img",
    "-append", f"{params} console=tty1 console=ttyS0,115200",
    "-cdrom", ISO, *disco,
    "-vga", "virtio", "-display", "none",
    "-nic", "user,model=virtio-net-pci,ipv6=off",
    "-chardev", f"socket,id=s0,path={serial_sock},server=on,wait=off,logfile={OUT}/serial.log",
    "-serial", "chardev:s0",
    "-monitor", f"unix:{mon_sock},server,nowait",
])

for _ in range(50):
    if os.path.exists(serial_sock) and os.path.exists(mon_sock):
        break
    if qemu.poll() is not None:
        sys.exit(f"O QEMU terminou com o código {qemu.returncode}")
    time.sleep(0.2)

ser = socket.socket(socket.AF_UNIX)
ser.connect(serial_sock)
ser.settimeout(1)
buf = ""


def ler(ate, timeout):
    """Lê da porta série até aparecer o padrão (regex) ou acabar o tempo."""
    global buf
    fim = time.time() + timeout
    while time.time() < fim:
        m = re.search(ate, buf)
        if m:
            texto = buf[:m.end()]
            buf = buf[m.end():]
            return texto
        try:
            dados = ser.recv(4096)
            if dados:
                buf += dados.decode(errors="replace")
        except socket.timeout:
            pass
    raise TimeoutError(f"não apareceu {ate!r}; último texto:\n{buf[-2000:]}")


def captura(nome):
    m = socket.socket(socket.AF_UNIX)
    m.connect(mon_sock)
    m.sendall(f"screendump {OUT}/{nome}.ppm\n".encode())
    time.sleep(2)
    m.close()
    subprocess.run(["magick", f"{OUT}/{nome}.ppm", f"{OUT}/{nome}.png"], check=False)
    print(f"captura: {OUT}/{nome}.png")


MARCA = "__BONVEL_FIM__"


def cmd(c, timeout=60):
    ser.sendall(f"{c}; echo {MARCA}$?\n".encode())
    texto = ler(rf"{MARCA}(\d+)", timeout)
    codigo = re.search(rf"{MARCA}(\d+)", texto).group(1)
    # O eco está desligado (stty -echo): só sobra o prompt do comando anterior
    saida = re.sub(rf"{MARCA}\d+$", "", texto)
    saida = re.sub(r"\x1b\[[0-9;?]*[a-zA-Z]", "", saida).replace("\r", "").strip()
    saida = re.sub(r"^(# )+", "", saida)
    return int(codigo), saida


try:
    t0 = time.time()
    ler(r"login:", 240)
    print(f"Arranque até ao login na série: {time.time() - t0:.0f}s")
    ser.sendall(b"root\n")
    ler(r"[#%] ", 30)
    time.sleep(1)
    # bash simples em vez do zsh do root: sem cores, sem erros de glob vazio
    ser.sendall(b"exec env TERM=dumb PS1='# ' bash --norc --noprofile\n")
    time.sleep(2)
    ser.sendall(b"shopt -s nullglob; stty -echo\n")
    time.sleep(2)
    buf = ""

    # Dá tempo ao Hyprland do tty1
    time.sleep(40)
    captura("01-tty1")

    verificacoes = [
        ("hostname", "hostname"),
        ("sistema arrancou", "systemctl is-system-running --wait; systemctl --failed --no-legend"),
        ("Hyprland a correr", "pgrep -a Hyprland"),
        ("waybar/mako/swaybg", "pgrep -l 'waybar|mako|swaybg'"),
        ("scripts executáveis", "ls -l /opt/scripts/ /usr/local/bin/ | grep -v total"),
        ("links dos comandos", "for c in hacked cktor fp IRN post_install scriptT bonvel-tema bonvel-atalhos ubermensch; do command -v $c >/dev/null && test -x $(readlink -f $(command -v $c)) && echo \"ok $c\" || echo \"FALHA $c\"; done"),
        ("config do root", "test -L /root/.config && echo LINK || echo copia; ls /root/.config/"),
        ("skel limpo", "ls -A /etc/skel/.config/; test -e /etc/skel/.config/dconf && echo SUJO || echo limpo"),
        ("tema atual", "readlink /root/.config/omarchy/current/theme /root/.config/omarchy/current/background; test -f /root/.config/omarchy/current/background && echo fundo-ok"),
        ("sintaxe dos scripts", "for f in /opt/scripts/*.sh /opt/scripts/scriptT /usr/local/bin/bonvel-*; do bash -n $f || echo ERRO $f; done; echo verificado"),
        ("lista de temas", "bonvel-tema --lista"),
        ("chaves pacman", "systemctl is-active pacman-init; pacman-key --list-keys F9A6E68A711354D84A9B91637533BAFE69A25079 | head -2"),
        ("repo blackarch", "pacman -Sy >/dev/null 2>&1; echo sync=$?; echo pacotes_blackarch=$(pacman -Sl blackarch 2>/dev/null | wc -l)"),
        ("rede", "ip -br a; ping -c1 -W3 archlinux.org | tail -2"),
        ("ferramentas", "for b in Hyprland foot ghostty waybar wofi mako firefox nmap hydra msfconsole sqlmap john aircrack-ng tshark tor torsocks feh lolcat mpv python3 hyprlock hypridle swaybg grim wpctl; do command -v $b >/dev/null || echo FALTA $b; done; echo verificado"),
        ("erros do Hyprland", "f=$(ls -t /run/user/0/hypr/*/hyprland.log 2>/dev/null | head -1); echo log=$f; grep -iE 'error|fail' $f | grep -v 'no error' | head -20"),
        ("pacotes desktop", "grep -vcE '^\\s*(#|$)' /usr/share/bonvel/pacotes-desktop.txt; cat /etc/profile.d/bonvel-hyprland.sh | head -3"),
        ("motd", "head -3 /etc/motd"),
        ("os-release", "grep PRETTY_NAME /etc/os-release"),
        ("config do foot", "foot --check-config && echo foot-ok"),
        ("config do Ghostty", "ghostty +validate-config --config-file=/etc/skel/.config/ghostty/config && echo ghostty-ok"),
        ("arranque do Hyprland", "pgrep -a start-hyprland; f=$(ls -t /run/user/0/hypr/*/hyprland.log | head -1); grep -ci 'without start-hyprland' $f"),
        ("cow_spacesize", "grep -o 'cow_spacesize=[^ ]*' /proc/cmdline"),
        ("tamanho", "df -h /run/archiso/airootfs / 2>/dev/null | tail -2"),
    ]
    if SO_INSTALAR:
        verificacoes = []
    with open(f"{OUT}/relatorio.txt", "w") as rel:
        for nome, c in verificacoes:
            try:
                codigo, saida = cmd(c, timeout=180)
            except TimeoutError as e:
                codigo, saida = -1, str(e)
            bloco = f"=== {nome} (código {codigo})\n{saida}\n"
            print(bloco)
            rel.write(bloco)

    if INSTALAR:
        instalacao = [
            ("cache e mirror do PC", "mkdir -p /hostcache && mount -t 9p -o trans=virtio,version=9p2000.L,ro hostcache /hostcache"
                " && sed -i '/^\\[options\\]/a CacheDir = /hostcache/\\nCacheDir = /var/cache/pacman/pkg/\\nDisableDownloadTimeout' /etc/pacman.conf"
                f" && echo 'Server = {MIRROR}' > /etc/pacman.d/mirrorlist && pacman -Sy >/dev/null && ls /hostcache | wc -l", 120),
            ("particionar e montar", "parted -s /dev/vda mklabel gpt mkpart root ext4 1MiB 100% && mkfs.ext4 -qF /dev/vda1 && mount /dev/vda1 /mnt && echo montado", 120),
            ("pacstrap base", "pacstrap -K -c /mnt base >/tmp/pacstrap.log 2>&1; echo pacstrap=$?; grep -iE 'error|erro|warn|space|failed' /tmp/pacstrap.log | head -20; tail -5 /tmp/pacstrap.log; df -h /mnt / /tmp", 1800),
            ("criar utilizador", "arch-chroot /mnt useradd -m -s /bin/bash teste && echo ok", 60),
            ("cache no disco", "mkdir -p /mnt/hostcache && mount --bind /hostcache /mnt/hostcache"
                " && sed -i '/^\\[options\\]/a CacheDir = /hostcache/\\nCacheDir = /var/cache/pacman/pkg/\\nDisableDownloadTimeout' /mnt/etc/pacman.conf && echo ok", 60),
            *([("injetar post_install local", "mkdir -p /bvscripts && mount -t 9p -o trans=virtio,version=9p2000.L,ro bvscripts /bvscripts"
                " && cp /bvscripts/post_install.sh /opt/scripts/post_install.sh && chmod 755 /opt/scripts/post_install.sh && grep -c adicionar_blackarch /opt/scripts/post_install.sh", 60)] if INJETAR else []),
            ("post_install", "/opt/scripts/post_install.sh /mnt >/tmp/post.log 2>&1; echo post_install=$?; grep -E '==>|rro|warning|Aviso' /tmp/post.log | tail -15", 3600),
            ("pacotes no disco", "arch-chroot /mnt pacman -Q hyprland firefox metasploit 2>&1 | head; for p in $(grep -vE '^\\s*(#|$)' /usr/share/bonvel/pacotes-desktop.txt); do arch-chroot /mnt pacman -Q $p >/dev/null 2>&1 || echo FALTA $p; done; echo verificado", 300),
            ("scripts no disco", "ls -l /mnt/opt/scripts/ /mnt/usr/local/bin/ | grep -v total", 60),
            ("home do utilizador", "ls -la /mnt/home/teste/ /mnt/home/teste/.config/; stat -c '%U %n' /mnt/home/teste/.config/hypr /mnt/home/teste/.config/omarchy/current/theme; readlink /mnt/home/teste/.config/omarchy/current/theme", 60),
            ("blackarch no disco", "grep -A2 '^\\[blackarch\\]' /mnt/etc/pacman.conf; echo pacotes_blackarch=$(arch-chroot /mnt pacman -Sl blackarch 2>/dev/null | wc -l)", 120),
            ("arranque automático", "cat /mnt/etc/profile.d/bonvel-hyprland.sh | tail -3", 60),
            ("config Hyprland do utilizador", "arch-chroot /mnt su - teste -c 'XDG_RUNTIME_DIR=/tmp Hyprland --verify-config 2>&1 | tail -1'", 120),
            ("comandos do utilizador", "arch-chroot /mnt su - teste -c 'bonvel-tema --lista; for c in hacked cktor fp IRN scriptT bonvel-atalhos ubermensch; do command -v $c >/dev/null && echo ok $c || echo FALHA $c; done'", 60),
        ]
        with open(f"{OUT}/relatorio.txt", "a") as rel:
            for nome, c, t in instalacao:
                try:
                    codigo, saida = cmd(c, timeout=t)
                except TimeoutError as e:
                    codigo, saida = -1, str(e)
                bloco = f"=== [instalação] {nome} (código {codigo})\n{saida}\n"
                print(bloco, flush=True)
                rel.write(bloco)

    # Testa a troca de tema dentro do Hyprland e tira outra captura
    cmd("export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/0/hypr/ | head -1) XDG_RUNTIME_DIR=/run/user/0 WAYLAND_DISPLAY=wayland-1; bonvel-tema LainOm", 60)
    time.sleep(5)
    captura("02-tema-lainom")
    cmd("bonvel-tema snow_black; setsid -f foot >/dev/null 2>&1", 60)
    time.sleep(5)
    captura("03-terminal")

    # Modo Übermensch: liga, verifica fundo, shader, waybar e mako; desliga e verifica o regresso
    verif = ("readlink ~/.config/omarchy/current/background; ubermensch estado; "
             "hyprctl getoption decoration:screen_shader | head -1; "
             "hyprctl getoption animations:enabled | head -1; makoctl mode; "
             "cat ~/.local/state/bonvel/ubermensch/ghostty.conf 2>/dev/null || echo sem-relampagos")
    uber = [
        ("übermensch: ligar", "ubermensch >/dev/null; echo rc=$?; setsid -f ghostty >/dev/null 2>&1; " + verif),
        ("übermensch: desligar", "ubermensch off; " + verif),
    ]
    with open(f"{OUT}/relatorio.txt", "a") as rel:
        for i, (nome, c) in enumerate(uber):
            codigo, saida = cmd(c, 60)
            bloco = f"=== {nome} (código {codigo})\n{saida}\n"
            print(bloco, flush=True)
            rel.write(bloco)
            time.sleep(5)
            captura(f"0{4 + i}-ubermensch-{'on' if i == 0 else 'off'}")
finally:
    try:
        ser.sendall(b"poweroff\n")
        qemu.wait(timeout=60)
    except Exception:
        qemu.kill()
print(f"Relatório: {OUT}/relatorio.txt")
