# ~/.zshrc

# ---------------------------------------------------------------- environment

# Homebrew (macOS; Apple Silicon or Intel)
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x $brew ]] && eval "$($brew shellenv)" && break
done

typeset -U path                 # no duplicate PATH entries
path=("$HOME/.local/bin" $path)

export EDITOR=nvim VISUAL=nvim
export MANPAGER="nvim +Man!"

# macOS: Neovim's sockets go under $TMPDIR by default, which is too long for the ~103-character
# socket path limit when the username is long (fzf-lua then fails to start its server)
if [[ $OSTYPE == darwin* ]]; then
    export XDG_RUNTIME_DIR="$HOME/.cache/run"
    [[ -d $XDG_RUNTIME_DIR ]] || mkdir -p -m 700 "$XDG_RUNTIME_DIR"
fi

# ---------------------------------------------------------------- history and options

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
[[ -d ${HISTFILE:h} ]] || mkdir -p "${HISTFILE:h}"
HISTSIZE=50000
SAVEHIST=50000
setopt share_history            # all open shells share one history
setopt hist_ignore_all_dups     # keep only the latest copy of a repeated command
setopt hist_ignore_space        # a command starting with a space isn't saved
setopt extended_history         # save timestamps

setopt auto_cd                  # type a folder name to cd into it
setopt interactive_comments     # allow # comments on the command line
setopt no_beep

# ---------------------------------------------------------------- completion

autoload -Uz compinit
zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
[[ -d ${zcompdump:h} ]] || mkdir -p "${zcompdump:h}"
# Full check (slow) at most once a day; otherwise reuse the saved cache
if [[ -n $zcompdump(#qN.mh-24) ]]; then compinit -C -d "$zcompdump"; else compinit -d "$zcompdump"; fi
zstyle ':completion:*' menu select                          # pick with the arrow keys / Tab
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ---------------------------------------------------------------- plugins
#
# Cloned on first start into ~/.local/share/zsh/plugins; `zsh-plugins-update` updates them.

ZSH_PLUGINS="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
plugins=(
    jeffreytse/zsh-vi-mode              # Vim modes on the command line
    zsh-users/zsh-autosuggestions       # grey suggestion from history as you type
    zsh-users/zsh-syntax-highlighting   # colours commands as you type (must load last)
)

for repo in $plugins; do
    dir="$ZSH_PLUGINS/${repo:t}"
    [[ -d $dir ]] || git clone --quiet --depth 1 "https://github.com/$repo" "$dir"
done

zsh-plugins-update() {
    for dir in "$ZSH_PLUGINS"/*(/); do
        echo "${dir:t}"; git -C "$dir" pull --quiet --ff-only
    done
}

# zsh-vi-mode: Esc for normal mode (w, b, ciw, dd, ...), vv opens the command in Neovim.
# It resets key bindings when it starts, so other bindings go in zvm_after_init.
source "$ZSH_PLUGINS/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
zvm_after_init() {
    source <(fzf --zsh)             # Ctrl+r history, Ctrl+t files, Alt+c folders
    bindkey '^y' autosuggest-accept # Ctrl+y accepts the suggestion, like completion in Neovim
    # Up/Down only go through commands starting with what's typed (nvim + Up: the last nvim ...)
    local keymap
    for keymap in viins vicmd; do
        bindkey -M $keymap '^[[A' up-line-or-beginning-search
        bindkey -M $keymap '^[[B' down-line-or-beginning-search
        bindkey -M $keymap '^[OA' up-line-or-beginning-search   # same keys in application mode
        bindkey -M $keymap '^[OB' down-line-or-beginning-search
    done
}

source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ---------------------------------------------------------------- tools

# Plain `tmux` attaches to the most recent session instead of adding a new one each time.
# With no server running it starts one, and tmux-continuum restores the saved sessions
# (tmux-resurrect then removes the startup session "0"). Any arguments work as usual.
tmux() {
    if (( $# == 0 )); then
        command tmux attach 2>/dev/null || command tmux new-session
    else
        command tmux "$@"
    fi
}

# Node versions: switches automatically when a folder has .nvmrc / .node-version
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd --shell zsh)"

if [[ $OSTYPE == darwin* ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi

# ---------------------------------------------------------------- prompt (Everforest)
#
#   ~/dotfiles  main*          folder, git branch (* unstaged, + staged changes), (venv)
#   ❯                          red after a failed command
#
# Vi mode is shown by the cursor: bar in insert mode, block in normal mode.

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats ' %F{#d699b6} %b%f%F{#dbbc7f}%u%c%f'
zstyle ':vcs_info:git:*' actionformats ' %F{#d699b6} %b%f %F{#e67e80}(%a)%f%F{#dbbc7f}%u%c%f'

export VIRTUAL_ENV_DISABLE_PROMPT=1     # the prompt shows the venv itself

precmd() {
    vcs_info
    print -P "\n%F{#a7c080}%~%f${vcs_info_msg_0_}${VIRTUAL_ENV:+ %F{#859289\}(${VIRTUAL_ENV:t})%f}"
}
PROMPT='%(?.%F{#a7c080}.%F{#e67e80})❯%f '

# Machine-specific settings and secrets, kept out of this repo: every file in ~/.config/zsh/local
for f in ~/.config/zsh/local/*.zsh(N); do source "$f"; done
unset f
