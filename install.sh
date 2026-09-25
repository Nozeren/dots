#!/usr/bin/env bash
# Set up these dotfiles on Arch Linux or macOS.
#
#   ./install.sh                 everything: packages, links (asks first), Neovim tools, shell
#   ./install.sh packages        only install packages
#   ./install.sh link [pkg...]   only link configs: the ones named, or all of them (asks first)
#   ./install.sh nvim            only install Neovim plugins, language servers and parsers
#   ./install.sh update          pull the repo, update packages, re-link, update all plugins
#
# Safe to re-run: installed packages are skipped and links are refreshed. Files a link
# would replace are moved to ~/.dotfiles-backup/<timestamp>/ first.
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

# What linking a config would replace, one path per line (relative to $HOME):
#  - real files (not already our symlinks) at the same place as a file in the package
#  - old locations that would shadow the new one (tmux reads ~/.tmux.conf first)
#  - for nvim: a whole existing ~/.config/nvim folder and its old plugin data, so the new
#    config is linked as one clean folder instead of being mixed into the old one
conflicts() {
    local pkg="$1"
    if [ "$pkg" = nvim ]; then
        if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
            echo ".config/nvim"
            [ -d "$HOME/.local/share/nvim" ] && echo ".local/share/nvim"
        fi
        return
    fi
    local f
    { (cd "$DOTFILES/$pkg" && find . -type f); if [ "$pkg" = tmux ]; then echo "./.tmux.conf"; fi; } | while read -r f; do
        f="${f#./}"
        [ -e "$HOME/$f" ] || continue
        # Already ours if it resolves into the repo (the file or a parent folder is our link)
        [ "$(realpath "$HOME/$f")" = "$(realpath "$DOTFILES/$pkg/$f" 2>/dev/null)" ] && continue
        echo "$f"
    done
}

link_configs() {
    local packages=("$@")
    [ ${#packages[@]} -gt 0 ] || packages=("${CONFIGS[@]}")
    command -v stow >/dev/null || fail "GNU Stow is missing; run ./install.sh packages first"

    local backup="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
    for pkg in "${packages[@]}"; do
        [ -d "$DOTFILES/$pkg" ] || fail "No config named $pkg"
        conflicts "$pkg" | while read -r f; do
            mkdir -p "$backup/$(dirname "$f")"
            mv "$HOME/$f" "$backup/$f"
            echo "    backed up ~/$f"
        done
        info "Linking $pkg"
        stow --dir="$DOTFILES" --target="$HOME" --restow "$pkg"
    done

    if [ -d "$backup" ]; then info "Old files saved in $backup"; fi
}

# Show what linking would replace and ask; defaults to no
confirm_link() {
    local pkg list=""
    for pkg in "${CONFIGS[@]}"; do
        list+="$(conflicts "$pkg" | sed 's|^|    ~/|')"$'\n'
    done
    list="$(printf '%s' "$list" | sed '/^$/d')"
    if [ -z "$list" ]; then return 0; fi

    info "Linking the configs (${CONFIGS[*]}) would replace:"
    printf '%s\n' "$list"
    echo "    (they would be moved to ~/.dotfiles-backup/, not deleted)"
    if ! { true </dev/tty; } 2>/dev/null; then
        echo "    No terminal to ask on; skipping. Link specific configs with ./install.sh link <name>."
        return 1
    fi
    local answer
    read -r -p "Replace them? [y/N] " answer </dev/tty
    [[ "$answer" =~ ^[Yy]$ ]]
}

# ---------------------------------------------------------------- neovim

setup_nvim() {
    command -v nvim >/dev/null || fail "Neovim is missing; run ./install.sh packages first"
    info "Installing Neovim plugins, language servers, formatters and parsers (can take a few minutes)"
    # Explicit config dir, so this works before (or without) the config being linked
    XDG_CONFIG_HOME="$DOTFILES/nvim/.config" nvim --headless -c "lua require('config.bootstrap')"
}

# ---------------------------------------------------------------- update

# Configs that are already linked (so re-linking picks up new files, and nothing else is touched)
linked_configs() {
    local pkg marker
    for pkg in "${CONFIGS[@]}"; do
        case "$pkg" in
            zsh)   marker=".zshrc" ;;
            tmux)  marker=".config/tmux/tmux.conf" ;;
            nvim)  marker=".config/nvim/init.lua" ;;
            kitty) marker=".config/kitty/kitty.conf" ;;
        esac
        [ "$(realpath "$HOME/$marker" 2>/dev/null)" = "$DOTFILES/$pkg/$marker" ] && echo "$pkg"
    done
}

update_all() {
    if [ "${1:-}" != "--pulled" ]; then
        info "Pulling the latest dotfiles"
        local before; before="$(sha1sum "$0" 2>/dev/null || shasum "$0")"
        git -C "$DOTFILES" pull --ff-only || fail "git pull failed; sort out the repo and run again"
        # If this script itself changed, continue with the new version
        if [ "$before" != "$(sha1sum "$0" 2>/dev/null || shasum "$0")" ]; then
            exec "$DOTFILES/install.sh" update --pulled
        fi
    fi

    install_packages

    local linked; linked="$(linked_configs | tr '\n' ' ')"
    if [ -n "${linked// /}" ]; then
        # shellcheck disable=SC2086
        link_configs $linked
    fi

    if command -v nvim >/dev/null; then
        info "Updating Neovim plugins, language servers, formatters and parsers"
        XDG_CONFIG_HOME="$DOTFILES/nvim/.config" nvim --headless -c "lua require('config.update')"
    fi

    local dir
    if [ -d "$HOME/.local/share/zsh/plugins" ]; then
        info "Updating zsh plugins"
        for dir in "$HOME"/.local/share/zsh/plugins/*/; do
            echo "    $(basename "$dir")"; git -C "$dir" pull --quiet --ff-only
        done
    fi
    if [ -x "$HOME/.local/share/tmux/plugins/tpm/bin/update_plugins" ]; then
        info "Updating tmux plugins"
        "$HOME/.local/share/tmux/plugins/tpm/bin/update_plugins" all | sed 's/^/    /'
    fi

    if ! git -C "$DOTFILES" diff --quiet -- nvim/.config/nvim/nvim-pack-lock.json; then
        info "Neovim plugins changed: commit nvim/.config/nvim/nvim-pack-lock.json so other machines match"
    fi
    info "Up to date. Restart Neovim and open a new shell to use the updates."
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
        if confirm_link; then
            link_configs
        else
            info "Configs not linked"
        fi
        setup_nvim
        set_default_shell
        info "Done ($OS). Open a new terminal to pick everything up."
        ;;
    packages) install_packages ;;
    link)
        # Naming configs is deliberate; linking all of them asks first, like a full install
        if [ $# -gt 0 ]; then
            link_configs "$@"
        elif confirm_link; then
            link_configs
        else
            info "Configs not linked"
        fi
        ;;
    nvim)     setup_nvim ;;
    update)   update_all "$@" ;;
    -h|--help|help) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//' ;;
    *)        fail "Unknown command: $cmd (try ./install.sh help)" ;;
esac
