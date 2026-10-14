# BonVel OS

Distribuição Linux baseada em Arch Linux, construída com [archiso](https://wiki.archlinux.org/title/Archiso).
Arranca num ambiente Hyprland com o tema snow_black e traz ferramentas de segurança (metasploit, hydra, sqlmap, john, aircrack-ng, wireshark-cli, nmap).

Criado por Hussein ([BON333](https://github.com/BON333)) e Kleyton ([Mente-MiIionaria](https://github.com/Mente-MiIionaria)).

## Construir a ISO

Num Arch Linux com `archiso` instalado:

```bash
tools/build.sh          # ISO em ~/iso_out
tools/runSystem.sh      # testa a ISO mais recente no QEMU (UEFI)
tools/test-arranque.sh  # capturas do menu de arranque em BIOS e UEFI
tools/test-iso.py       # teste automático: arranca a ISO sem janela, verifica serviços,
                        # scripts, temas, Hyprland e o modo Übermensch, e tira capturas de ecrã
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
| `SUPER + ENTER` | Terminal (Ghostty) |
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
| `ubermensch` | Liga o modo Übermensch (ver abaixo) |
| `cktor` | Verifica se o Tor está a funcionar |
| `fp` | tmux com ping colorido |
| `hacked`, `IRN` | Brincadeiras visuais (o `IRN` pergunta antes de reiniciar) |
| `scriptT` | Registo de estudante |

## Modo Übermensch

Escreve `ubermensch` no terminal (ou carrega em `SUPER + U`) e o ambiente muda:

- fundo `End.jpg`;
- ecrã a preto e branco (shader `grayscale.glsl`);
- terminal Ghostty preto com relâmpagos brancos sem parar (shader `relampagos.glsl`; as janelas já abertas mudam na hora);
- bordas brancas, mais espaço entre janelas, sem animações nem blur;
- notificações em "não incomodar" (os avisos do `notify-send` continuam a aparecer);
- perfil de energia `performance`, se o `powerprofilesctl` estiver instalado;
- `fastfetch` com logótipo próprio e uma frase de Nietzsche;
- **Ü** na waybar (clicar desliga o modo) e uma frase no ecrã de bloqueio.

| Comando | O que faz |
|---|---|
| `ubermensch` | Liga o modo |
| `ubermensch off` | Volta ao fundo e às definições anteriores |
| `ubermensch toggle` | Liga ou desliga (é o que o `SUPER + U` usa) |
| `ubermensch raios` | Tira ou repõe só os relâmpagos do Ghostty (`SUPER + ALT + O`); a escolha fica guardada |
| `ubermensch frase` | Mostra uma frase de Nietzsche |
| `ubermensch pomodoro [min]` | Temporizador com aviso no fim (25 minutos por omissão) |
| `ubermensch sessao` | Inicia o Tor, corre o `cktor` e abre um tmux com as janelas recon, notas e shell |

As frases, o logótipo e os shaders estão em `/usr/share/bonvel/ubermensch/`.

O modo também tem repositório próprio, para instalar no Omarchy ou noutro Hyprland: [BON333/ubermensch](https://github.com/BON333/ubermensch).

## Shaders do ecrã

Em `~/.config/hypr/shaders/` há 137 shaders para o Hyprland (preto e branco, CRT, matrix, visão noturna, filtros para daltonismo e outros).
Vêm do projeto [Aether](https://github.com/bjarneo/aether) (licença MIT).

```bash
hyprctl keyword decoration:screen_shader ~/.config/hypr/shaders/noir.glsl   # aplicar
hyprctl keyword decoration:screen_shader "[[EMPTY]]"                        # remover
```

Os shaders mais simples (cores, preto e branco) quase não gastam nada; os animados, como o `matrix-rain`, pesam um pouco mais na placa gráfica.

## Estrutura

| Caminho | Conteúdo |
|---|---|
| `profiledef.sh` | Nome da ISO, modos de arranque, permissões dos ficheiros |
| `packages.x86_64` | Pacotes instalados na ISO |
| `pacman.conf` | Repositórios (core, extra, multilib, blackarch) |
| `airootfs/` | Ficheiros copiados para o sistema ao vivo |
| `airootfs/etc/skel/.config/` | Hyprland, waybar, Ghostty, foot, wofi, mako e temas |
| `airootfs/opt/scripts/` | Scripts do BonVel |
| `airootfs/usr/local/bin/` | Comandos `bonvel-tema`, `bonvel-atalhos` e `ubermensch` |
| `airootfs/usr/share/bonvel/` | Página inicial do Firefox, lista de pacotes e ficheiros do modo Übermensch |
| `airootfs/etc/skel/.config/hypr/shaders/` | Shaders do ecrã (Aether) |
| `syslinux/`, `efiboot/`, `grub/` | Menus de arranque (BIOS e UEFI) |
| `tools/` | Scripts para construir e testar (não vão para a ISO) |
