# BonVel OS

[Português](README.md) | [English](README.en.md)

An Arch Linux distribution built with [archiso](https://wiki.archlinux.org/title/Archiso).
It boots into a Hyprland desktop with the snow_black theme and includes security tools (metasploit, hydra, sqlmap, john, aircrack-ng, wireshark-cli, nmap).

Created by Hussein ([BON333](https://github.com/BON333)) and Kleyton ([Mente-MiIionaria](https://github.com/Mente-MiIionaria)).

## Build the ISO

On Arch Linux with `archiso` installed:

```bash
tools/build.sh          # ISO in ~/iso_out
tools/runSystem.sh      # boots the latest ISO in QEMU (UEFI)
tools/test-arranque.sh  # screenshots of the BIOS and UEFI boot menus
tools/test-iso.py       # automated test: boots the ISO headlessly, checks services,
                        # scripts, themes, Hyprland, and Übermensch Mode, and takes screenshots
tools/capturas.py       # generates the README images in docs/ (themes, welcome screen, Übermensch GIF)
```

The first time it runs, `build.sh` signs the BlackArch repository key because `pacman.conf` requires valid signatures.

## Install to disk

In the live system, run `bonvel-instalar`. It handles the following steps in order:

1. Checks the internet connection and opens `iwctl` if you need Wi-Fi.
2. Opens `archinstall` with recommendations for BonVel: choose the **Minimal** profile, create a user with sudo access, select "Copy ISO network configuration", and choose **Exit archinstall** at the end (not "Reboot system").
3. Runs `post_install`, which installs BonVel packages to disk and copies its scripts, themes, and settings to `/mnt`.
4. Asks whether you want to reboot. After rebooting, log in with your user account on tty1; Hyprland starts automatically.

If you rebooted before step 3, boot the ISO again and run `bonvel-instalar --sem-archinstall`. It finds and mounts the installed system, then installs BonVel. The manual steps still work too: run `archinstall`, then `post_install` before rebooting.

In the ISO, the desktop runs as `bonvel`, a regular user. On first boot, set a password for the session; `sudo` will ask for it, and automatic screen locking is available. SSH is disabled by default; to start it manually, run `sudo systemctl start sshd`. Root remote login is blocked.

## Main shortcuts

| Shortcut | Action |
|---|---|
| `SUPER + ENTER` | Terminal (Ghostty) |
| `SUPER + SPACE` | Application menu (wofi) |
| `SUPER + SHIFT + B` | Firefox |
| `SUPER + W` | Close window |
| `SUPER + K` | Show all shortcuts |
| `SUPER + CTRL + T` | Switch theme |
| `SUPER + U` | Toggle Übermensch Mode |
| `SUPER + 1…0` | Workspaces |
| `PRINT` | Region screenshot |

## BonVel commands

| Command | Description |
|---|---|
| `bonvel-tema [name]` | Switch theme (snow_black, LainOm, greek-noir, gruvu, latchdark; creators in the [credits](../README.en.md#theme-credits)) |
| `bonvel-atalhos` | List Hyprland shortcuts |
| `bonvel-instalar` | Install BonVel to disk (live system only) |
| `bonvel-boas-vindas` | Welcome screen with the main shortcuts (opens automatically on first boot) |
| `ubermensch` | Toggle Übermensch Mode (see below) |
| `cktor` | Check whether Tor is working |
| `fp` | tmux with a colored ping |
| `hacked`, `IRN` | Visual pranks (`IRN` asks before rebooting) |
| `scriptT` | Student record |

## Übermensch Mode

Run `ubermensch` in a terminal (or press `SUPER + U`) to change the desktop:

- `End.jpg` background;
- black-and-white display (`grayscale.glsl` shader);
- black Ghostty terminal with continuous white lightning (`relampagos.glsl` shader; already-open windows update immediately);
- white borders, wider gaps between windows, no animations or blur;
- notifications set to "do not disturb" (`notify-send` messages still appear);
- `performance` power profile, if `powerprofilesctl` is installed;
- `fastfetch` with a custom logo and a Nietzsche quote;
- **Ü** in waybar (click it to turn the mode off) and a quote on the lock screen.

| Command | Description |
|---|---|
| `ubermensch` | Turn the mode on |
| `ubermensch off` | Restore the previous background and settings |
| `ubermensch toggle` | Turn the mode on or off (used by `SUPER + U`) |
| `ubermensch raios` | Toggle only the Ghostty lightning (`SUPER + ALT + O`); the choice is saved |
| `ubermensch frase` | Show a Nietzsche quote |
| `ubermensch pomodoro [min]` | Timer with an alert when it ends (25 minutes by default) |
| `ubermensch sessao` | Starts Tor, runs `cktor`, and opens tmux with recon, notes, and shell windows |

The quotes, logo, and shaders are in `/usr/share/bonvel/ubermensch/`.

Übermensch Mode also has its own repository for installation on Omarchy or another Hyprland setup: [BON333/ubermensch](https://github.com/BON333/ubermensch).

## Screen shaders

There are 137 shaders for Hyprland in `~/.config/hypr/shaders/` (black and white, CRT, matrix, night vision, color-blindness filters, and more).
They come from [Aether](https://github.com/bjarneo/aether) (MIT license).

```bash
hyprctl keyword decoration:screen_shader ~/.config/hypr/shaders/noir.glsl   # apply
hyprctl keyword decoration:screen_shader "[[EMPTY]]"                        # remove
```

Simple shaders (colors, black and white) use very few resources; animated ones, such as `matrix-rain`, put a bit more load on the graphics card.

## Structure

| Path | Contents |
|---|---|
| `profiledef.sh` | ISO name, boot modes, and file permissions |
| `packages.x86_64` | Packages installed in the ISO |
| `pacman.conf` | Repositories (core, extra, multilib, blackarch) |
| `airootfs/` | Files copied into the live system |
| `airootfs/etc/skel/.config/` | Hyprland, waybar, Ghostty, foot, wofi, mako, and themes |
| `airootfs/opt/scripts/` | BonVel scripts |
| `airootfs/usr/local/bin/` | `bonvel-tema`, `bonvel-atalhos`, `bonvel-boas-vindas`, and `ubermensch` commands |
| `airootfs/usr/share/bonvel/` | Firefox home page, package list, and Übermensch Mode files |
| `airootfs/etc/skel/.config/hypr/shaders/` | Screen shaders (Aether) |
| `syslinux/`, `efiboot/`, `grub/` | Boot menus (BIOS and UEFI) |
| `tools/` | Build and test scripts (not included in the ISO) |
