# WezTerm Config

Personal WezTerm setup with:

- WezTerm config
- terminal boot menu launcher
- patched Migu 2m Nerd Font files

## Install

From this repo:

```bash
mkdir -p ~/.config/wezterm ~/.local/bin ~/.local/share/fonts/migu-patched
cp wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua
cp bin/terminal-boot-menu ~/.local/bin/terminal-boot-menu
chmod +x ~/.local/bin/terminal-boot-menu
cp fonts/migu-patched/*.ttf ~/.local/share/fonts/migu-patched/
fc-cache -fv
```

WezTerm also uses these system fonts if available:

```text
JetBrains Mono
Symbols Nerd Font Mono
```

## Notes

The boot menu expects Tailscale hostnames configured in `bin/terminal-boot-menu`:

```bash
MAC_TS_NAME="julians-mac-mini"
LINUX_TS_NAME="ubuntu-dualboot"
```

Override remote usernames when launching WezTerm if needed:

```bash
BOOT_MAC_USER=julian BOOT_LINUX_USER=ubuntu wezterm
```
