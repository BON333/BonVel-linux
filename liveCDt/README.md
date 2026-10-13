# BonVel OS

Distribuição Linux baseada em Arch Linux, construída com [archiso](https://wiki.archlinux.org/title/Archiso).
Arranca num ambiente Hyprland com o tema snow_black e traz ferramentas de segurança (metasploit, hydra, sqlmap, john, aircrack-ng, wireshark-cli, nmap).

Autores: Hussein ([BON333](https://github.com/BON333)) e [Mente-MiIionaria](https://github.com/Mente-MiIionaria).

## Construir a ISO

Num Arch Linux com `archiso` instalado:

```bash
tools/build.sh          # ISO em ~/iso_out
tools/runSystem.sh      # testa a ISO mais recente no QEMU (UEFI)
tools/test-arranque.sh  # capturas do menu de arranque em BIOS e UEFI
tools/test-iso.py       # teste automático: arranca a ISO sem janela, verifica serviços,
                        # scripts, temas e Hyprland, e tira capturas de ecrã
```

O `build.sh` assina a chave do repositório BlackArch na primeira vez, porque o `pacman.conf` exige assinaturas válidas.

## Instalar no disco

No sistema ao vivo:

1. `archinstall`
2. Antes de reiniciar, com internet: `post_install` (instala os pacotes do BonVel no disco e copia os scripts, temas e configurações para `/mnt`)
3. Reinicia e entra com o teu utilizador no tty1: o Hyprland arranca sozinho

## Atalhos principais

| Atalho | Ação |
|---|---|
| `SUPER + ENTER` | Terminal (foot) |
| `SUPER + SPACE` | Menu de aplicações (wofi) |
| `SUPER + SHIFT + B` | Firefox |
| `SUPER + W` | Fechar janela |
| `SUPER + K` | Mostrar todos os atalhos |
| `SUPER + CTRL + T` | Trocar tema |
| `SUPER + U` | Ligar/desligar o modo Übermensch |
| `SUPER + 1…0` | Áreas de trabalho |
| `PRINT` | Captura de região |

## Comandos do BonVel

| Comando | O que faz |
|---|---|
| `bonvel-tema [nome]` | Troca o tema (snow_black, LainOm, greek-noir, gruvu, latchdark) |
| `bonvel-atalhos` | Lista os atalhos do Hyprland |
| `ubermensch` | Modo Übermensch: fundo `End.jpg`, ecrã a preto e branco, não incomodar. `ubermensch off` volta ao normal; também há `frase`, `pomodoro [min]` e `sessao` (Tor + tmux) |
| `cktor` | Verifica se o Tor está a funcionar |
| `fp` | tmux com ping colorido |
| `hacked`, `IRN` | Brincadeiras visuais (o `IRN` pergunta antes de reiniciar) |
| `scriptT` | Registo de estudante |

## Estrutura

| Caminho | Conteúdo |
|---|---|
| `profiledef.sh` | Nome da ISO, modos de arranque, permissões dos ficheiros |
| `packages.x86_64` | Pacotes instalados na ISO |
| `pacman.conf` | Repositórios (core, extra, multilib, blackarch) |
| `airootfs/` | Ficheiros copiados para o sistema ao vivo |
| `airootfs/etc/skel/.config/` | Hyprland, waybar, foot, wofi, mako e temas |
| `airootfs/opt/scripts/` | Scripts do BonVel |
| `syslinux/`, `efiboot/`, `grub/` | Menus de arranque (BIOS e UEFI) |
| `tools/` | Scripts para construir e testar (não vão para a ISO) |
