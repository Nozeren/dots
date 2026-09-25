#!/usr/bin/env bash
# Link the dotfiles into $HOME with GNU Stow, on Arch Linux or macOS.
#
#   ./install.sh              link every package
#   ./install.sh zsh tmux     link only these packages
#
# Existing files that would be replaced are moved to ~/.dotfiles-backup/<timestamp>/
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh tmux nvim kitty)
[ $# -gt 0 ] && PACKAGES=("$@")

case "$(uname -s)" in
    Darwin) OS=macos ;;
    Linux)  [ -f /etc/arch-release ] && OS=arch || OS=linux ;;
    *)      OS=unknown ;;
esac

if ! command -v stow >/dev/null; then
    echo "==> Installing GNU Stow"
    case "$OS" in
        macos) brew install stow ;;
        arch)  sudo pacman -S --needed --noconfirm stow ;;
        *)     echo "Install GNU Stow first" >&2; exit 1 ;;
    esac
fi

backup="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
for pkg in "${PACKAGES[@]}"; do
    [ -d "$DOTFILES/$pkg" ] || { echo "No package named $pkg" >&2; exit 1; }

    # Move aside real files (not our symlinks) that the package would replace
    (cd "$DOTFILES/$pkg" && find . -type f) | while read -r f; do
        target="$HOME/${f#./}"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            mkdir -p "$backup/$(dirname "${f#./}")"
            mv "$target" "$backup/${f#./}"
            echo "    backed up ~/${f#./}"
        fi
    done

    echo "==> Linking $pkg"
    stow --dir="$DOTFILES" --target="$HOME" --restow "$pkg"
done

[ -d "$backup" ] && echo "Old files saved in $backup"
echo "Done ($OS)."
