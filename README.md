# dotfiles

Configs for Arch Linux and macOS, linked into place with [GNU Stow](https://www.gnu.org/software/stow/).

All the keys (Neovim, tmux, zsh, kitty) are in [KEYS.md](KEYS.md).

| package | links to |
| ------- | -------- |
| `zsh`   | `~/.zshrc` |
| `tmux`  | `~/.config/tmux/tmux.conf` |
| `nvim`  | `~/.config/nvim/` |
| `kitty` | `~/.config/kitty/` |
| `wallpapers` | `~/.local/share/wallpapers/` (Everforest walls: streetlights on Arch, a street shop on macOS) |
| `hypr` | `~/.config/hypr/` (Arch only: Hyprland, hyprpaper, power menu and screenshot scripts) |
| `waybar` | `~/.config/waybar/` (Arch only) |
| `rofi` | `~/.config/rofi/` (Arch only: app launcher, power menu, clipboard popup) |
| `gtk` | `~/.config/gtk-3.0/gtk.css`, `~/.config/gtk-4.0/gtk.css` (Arch only: Everforest colours for GTK apps) |

Everything uses the Everforest dark hard palette: `hypr/colors.conf`, `waybar/colors.css`,
`rofi/colors.rasi` and `gtk/` hold the same colours in each program's format.
| `sddm/` | login screen (Arch only, not linked: `./install.sh login` copies it into place with sudo) |

## Install

On a new machine (Arch Linux or macOS):

```sh
git clone git@github.com:Nozeren/dots.git ~/dotfiles
~/dotfiles/install.sh
```

That installs the packages, links the configs and makes zsh the default shell.
It's safe to re-run whenever something is added.

| command | what it does |
| ------- | ------------ |
| `./install.sh` | everything below; before linking it lists the files it would replace and asks |
| `./install.sh packages` | install packages: `packages/arch.txt` with pacman (plus `packages/aur.txt` with yay), or `packages/Brewfile` with Homebrew (installed if missing) |
| `./install.sh link [pkg...]` | symlink configs into `$HOME` with Stow, no prompt; existing files are moved to `~/.dotfiles-backup/<timestamp>/` (for nvim: the whole old `~/.config/nvim` and `~/.local/share/nvim`) |
| `./install.sh nvim` | install Neovim plugins, language servers, formatters and treesitter parsers without opening Neovim (list in `nvim/.config/nvim/lua/config/tools.lua`) |
| `./install.sh login` | (Arch) apply the SilentSDDM login screen theme from `sddm/`, with the Streetlights wallpaper |
| `./install.sh update` | bring a machine up to date: pull this repo, update packages, re-link the configs that are linked, update Neovim plugins/language servers/formatters/parsers, zsh and tmux plugins. Commit `nvim-pack-lock.json` afterwards if it changed |

Edit files in `~/dotfiles`; the symlinks mean changes apply immediately.
When a config starts using a new tool, add it to both package lists.
