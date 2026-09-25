#!/usr/bin/env bash
# Set up these dotfiles on Arch Linux or macOS.
#
#   ./install.sh                 everything: packages, links, default shell
#   ./install.sh packages        only install packages
#   ./install.sh link [pkg...]   only link configs (all, or just the ones named)
#
# Safe to re-run: installed packages are skipped and links are refreshed.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS=(zsh tmux nvim kitty)

info() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

case "$(uname -s)" in
    Darwin) OS=macos ;;
    Linux)  [ -f /etc/arch-release ] && OS=arch || OS=linux ;;
    *)      OS=unknown ;;
esac

# ---------------------------------------------------------------- packages

ensure_brew() {
    command -v brew >/dev/null && return
    info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Apple Silicon and Intel Macs install brew to different places
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        [ -x "$b" ] && eval "$("$b" shellenv)" && break
    done
}

install_packages() {
    case "$OS" in
        arch)
            # An old keyring can reject packages signed by newer developer keys
            info "Updating the Arch keyring"
            sudo pacman -Sy --needed --noconfirm archlinux-keyring
            info "Installing packages with pacman (packages/arch.txt)"
            # -Syu rather than -S: Arch doesn't support partial upgrades
            sed 's/#.*//' "$DOTFILES/packages/arch.txt" | xargs sudo pacman -Syu --needed --noconfirm
            ;;
        macos)
            ensure_brew
            info "Installing packages with Homebrew (packages/Brewfile)"
            brew bundle --file="$DOTFILES/packages/Brewfile"
            ;;
        *)
            fail "No package list for this system; install the packages yourself and run: ./install.sh link"
            ;;
    esac
}

# ---------------------------------------------------------------- links

link_configs() {
    local packages=("$@")
    [ ${#packages[@]} -gt 0 ] || packages=("${CONFIGS[@]}")
    command -v stow >/dev/null || fail "GNU Stow is missing; run ./install.sh packages first"

    local backup="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
    for pkg in "${packages[@]}"; do
        [ -d "$DOTFILES/$pkg" ] || fail "No config named $pkg"

        # Move aside real files (not our symlinks) that the package would replace,
        # plus old locations that would shadow the new ones (tmux reads ~/.tmux.conf first)
        local legacy=""
        [ "$pkg" = tmux ] && legacy="./.tmux.conf"
        { (cd "$DOTFILES/$pkg" && find . -type f); if [ -n "$legacy" ]; then echo "$legacy"; fi; } | while read -r f; do
            local target="$HOME/${f#./}"
            if [ -e "$target" ] && [ ! -L "$target" ]; then
                mkdir -p "$backup/$(dirname "${f#./}")"
                mv "$target" "$backup/${f#./}"
                echo "    backed up ~/${f#./}"
            fi
        done

        info "Linking $pkg"
        stow --dir="$DOTFILES" --target="$HOME" --restow "$pkg"
    done

    if [ -d "$backup" ]; then info "Old files saved in $backup"; fi
}

# ---------------------------------------------------------------- shell

set_default_shell() {
    local zsh_path
    zsh_path="$(command -v zsh)" || return 0
    [ "$(basename "${SHELL:-}")" = zsh ] && return 0
    grep -qx "$zsh_path" /etc/shells || fail "$zsh_path is not listed in /etc/shells"
    info "Making zsh your default shell"
    chsh -s "$zsh_path"
}

# ---------------------------------------------------------------- main

cmd="${1:-all}"
[ $# -gt 0 ] && shift
case "$cmd" in
    all)
        install_packages
        link_configs
        set_default_shell
        info "Done ($OS). Open a new terminal to pick everything up."
        ;;
    packages) install_packages ;;
    link)     link_configs "$@" ;;
    -h|--help|help) sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//' ;;
    *)        fail "Unknown command: $cmd (try ./install.sh help)" ;;
esac
