# dotfiles

Configs for Arch Linux and macOS, linked into place with [GNU Stow](https://www.gnu.org/software/stow/).

| package | links to |
| ------- | -------- |
| `zsh`   | `~/.zshrc` |
| `tmux`  | `~/.config/tmux/tmux.conf` |
| `nvim`  | `~/.config/nvim/` |
| `kitty` | `~/.config/kitty/` |

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
| `./install.sh` | everything below |
| `./install.sh packages` | install packages: `packages/arch.txt` with pacman, or `packages/Brewfile` with Homebrew (installed if missing) |
| `./install.sh link [pkg...]` | symlink configs into `$HOME` with Stow; existing files are moved to `~/.dotfiles-backup/<timestamp>/` |

Edit files in `~/dotfiles`; the symlinks mean changes apply immediately.
When a config starts using a new tool, add it to both package lists.
