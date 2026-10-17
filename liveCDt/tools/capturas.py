#!/usr/bin/env python3
"""Tira as capturas de ecrã do README: arranca a ISO no QEMU (sem janela, não precisa de root),
abre terminais em cada tema, o ecrã de boas-vindas e o modo Übermensch (também em GIF).

Os comandos e configurações do repositório são injetados no sistema ao vivo por 9p,
para as capturas mostrarem o estado atual sem ter de recompilar a ISO.

Uso: tools/capturas.py [a.iso] [pasta]   (por omissão: a ISO mais recente e docs/ na raiz do repositório)
"""
import glob
import os
import re
import shutil
import socket
import subprocess
import sys
import tempfile
import time

AQUI = os.path.dirname(os.path.abspath(__file__))
ISO = sys.argv[1] if len(sys.argv) > 1 else max(glob.glob(os.path.expanduser("~/iso_out/*.iso")), key=os.path.getmtime)
DOCS = os.path.abspath(sys.argv[2] if len(sys.argv) > 2 else os.path.join(AQUI, "..", "..", "docs"))
AIROOTFS = os.path.abspath(os.path.join(AQUI, "..", "airootfs"))
TEMAS = ["snow_black", "LainOm", "greek-noir", "gruvu", "latchdark"]
os.makedirs(DOCS, exist_ok=True)
TMP = tempfile.mkdtemp(prefix="bv-", dir="/tmp")  # caminho curto: os sockets Unix têm limite de 108 bytes
print(f"ISO: {ISO}\nCapturas: {DOCS}")


def extrair(caminho_iso, destino):
    subprocess.run(["osirrox", "-indev", ISO, "-extract", caminho_iso, destino],
                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


# Arranca com o kernel e o initramfs da ISO, com os mesmos parâmetros da primeira entrada do menu
extrair("/arch/boot/x86_64/vmlinuz-linux", f"{TMP}/vmlinuz")
extrair("/arch/boot/x86_64/initramfs-linux.img", f"{TMP}/initramfs.img")
extrair("/boot/syslinux/archiso_sys-linux.cfg", f"{TMP}/sys-linux.cfg")
params = re.search(r"^APPEND (.+)$", open(f"{TMP}/sys-linux.cfg").read(), re.M).group(1)

serial_sock, mon_sock = f"{TMP}/serial", f"{TMP}/monitor"
qemu = subprocess.Popen([
    "qemu-system-x86_64", "-enable-kvm", "-machine", "q35", "-m", "4G", "-smp", "4", "-cpu", "host",
    "-kernel", f"{TMP}/vmlinuz", "-initrd", f"{TMP}/initramfs.img",
    "-append", f"{params} console=tty1 console=ttyS0,115200",
    "-cdrom", ISO,
    "-vga", "none", "-device", "virtio-vga,xres=1920,yres=1080", "-display", "none",
    "-nic", "user,model=virtio-net-pci,ipv6=off",
    "-virtfs", f"local,path={AIROOTFS},mount_tag=airootfs,security_model=none,readonly=on",
    "-chardev", f"socket,id=s0,path={serial_sock},server=on,wait=off",
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
            texto, buf = buf[:m.end()], buf[m.end():]
            return texto
        try:
            buf += ser.recv(4096).decode(errors="replace")
        except socket.timeout:
            pass
    raise TimeoutError(f"não apareceu {ate!r}; último texto:\n{buf[-2000:]}")


MARCA = "__BONVEL_FIM__"


def cmd(c, timeout=60):
    ser.sendall(f"{c}; echo {MARCA}$?\n".encode())
    texto = ler(rf"{MARCA}(\d+)", timeout)
    codigo = int(re.search(rf"{MARCA}(\d+)", texto).group(1))
    if codigo:
        print(f"aviso: '{c}' saiu com {codigo}:\n{texto}")
    return codigo


def screendump(destino):
    m = socket.socket(socket.AF_UNIX)
    m.connect(mon_sock)
    m.sendall(f"screendump {destino}\n".encode())
    m.recv(4096)
    # O QEMU escreve o ficheiro depois de responder: espera que fique completo
    for _ in range(50):
        time.sleep(0.1)
        if os.path.exists(destino) and os.path.getsize(destino) >= 1920 * 1080 * 3:
            break
    m.close()


def captura(nome):
    screendump(f"{TMP}/{nome}.ppm")
    subprocess.run(["magick", f"{TMP}/{nome}.ppm", "-quality", "92", f"{DOCS}/{nome}.webp"], check=True)
    print(f"captura: {DOCS}/{nome}.webp")


def gif(nome, quadros=24, intervalo=0.25):
    for i in range(quadros):
        screendump(f"{TMP}/{nome}-{i:02d}.ppm")
        time.sleep(intervalo)
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-framerate", str(round(1 / (intervalo + 0.1))),
                    "-i", f"{TMP}/{nome}-%02d.ppm",
                    "-vf", "scale=960:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=64[p];[b][p]paletteuse",
                    f"{DOCS}/{nome}.gif"], check=True)
    print(f"gif: {DOCS}/{nome}.gif")


SESSAO = ("export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/0/hypr/ | head -1) "
          "XDG_RUNTIME_DIR=/run/user/0 WAYLAND_DISPLAY=wayland-1")
# Ghostty com fastfetch à esquerda e o neovim (com as cores do tema) à direita
TERMINAIS = ("setsid -f ghostty -e bash -c 'clear; fastfetch; exec bash' >/dev/null 2>&1; sleep 3; "
             "setsid -f ghostty -e nvim -R /usr/local/bin/bonvel-tema >/dev/null 2>&1; sleep 4")
FECHAR = "pkill -x ghostty; pkill -f wofi; sleep 2"

try:
    ler(r"login:", 240)
    ser.sendall(b"root\n")
    ler(r"[#%] ", 30)
    time.sleep(1)
    ser.sendall(b"exec env TERM=dumb PS1='# ' bash --norc --noprofile\n")
    time.sleep(2)
    ser.sendall(b"stty -echo\n")
    time.sleep(2)
    buf = ""
    time.sleep(40)  # dá tempo ao Hyprland do tty1

    # Comandos e configurações do repositório por cima dos da ISO
    cmd("mkdir -p /repo && mount -t 9p -o trans=virtio,version=9p2000.L,ro airootfs /repo"
        " && find /repo/usr/local/bin -maxdepth 1 -type f -exec install -m755 {} /usr/local/bin/ \\;"
        " && install -m755 /repo/opt/scripts/*.sh /opt/scripts/"
        " && ln -sfn /opt/scripts/bonvel-instalar.sh /usr/local/bin/bonvel-instalar"
        " && cp -r /repo/etc/skel/.config/hypr/. /root/.config/hypr/"
        " && cp -r /repo/usr/share/bonvel/. /usr/share/bonvel/")
    cmd(SESSAO + "; hyprctl reload >/dev/null; sleep 2")

    # Aquecimento: no primeiro arranque o neovim demora e a captura sairia com a janela vazia
    cmd(f"{TERMINAIS}; sleep 5", 90)

    # Um ambiente de trabalho por tema
    for i, tema in enumerate(TEMAS, 1):
        cmd(f"{FECHAR}; bonvel-tema {tema} >/dev/null; sleep 3; {TERMINAIS}", 90)
        captura(f"tema-{i}-{tema}")

    # Ecrã de boas-vindas por cima do ambiente de trabalho (no sistema ao vivo, com a opção de instalar)
    cmd(f"{FECHAR}; bonvel-tema snow_black >/dev/null; sleep 3; {TERMINAIS}; "
        "setsid -f bonvel-boas-vindas >/dev/null 2>&1; sleep 4", 90)
    captura("boas-vindas")

    # Modo Übermensch: preto e branco e relâmpagos no Ghostty
    cmd(f"{FECHAR}; ubermensch >/dev/null; sleep 3; {TERMINAIS}", 90)
    captura("ubermensch")
    gif("ubermensch")
    cmd("ubermensch off >/dev/null")
finally:
    try:
        ser.sendall(b"poweroff\n")
        qemu.wait(timeout=60)
    except Exception:
        qemu.kill()
    shutil.rmtree(TMP, ignore_errors=True)
