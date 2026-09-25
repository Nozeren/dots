# dotfiles

Configs for Arch Linux and macOS, linked into place with [GNU Stow](https://www.gnu.org/software/stow/).

| package | links to |
| ------- | -------- |
| `zsh`   | `~/.zshrc` |
| `tmux`  | `~/.config/tmux/tmux.conf` |
| `nvim`  | `~/.config/nvim/` |
| `kitty` | `~/.config/kitty/` |

## Install

```sh
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh            # all packages
./install.sh tmux nvim  # just some
```

`install.sh` installs Stow if it's missing (pacman or Homebrew), moves any
existing files it would replace into `~/.dotfiles-backup/<timestamp>/`, and
symlinks each package into `$HOME`.

Edit files in `~/dotfiles`; the symlinks mean changes apply immediately.
