# Keys

Everything these dotfiles add, plus the built-in keys worth remembering.
`<leader>` is Space in Neovim; `prefix` is Ctrl+b in tmux.
In Neovim, `<leader>sk` searches this config's keys, `<leader>sK` all of them.

## Neovim

### Moving around

| key | does |
| --- | --- |
| `Ctrl+h/j/k/l` | move to the split (or tmux pane) left / down / up / right |
| `Ctrl+d` / `Ctrl+u` | half a page down / up, cursor centred |
| `n` / `N` | next / previous search match, centred |
| `Esc` | clear search highlight |
| `zc` / `zo` / `za` | close / open / toggle a fold |

### Files

| key | does |
| --- | --- |
| `-` | oil: open the current file's folder (edit names and `:w` to rename, `dd` + `:w` to trash) |
| `<leader>sf` | find files |
| `<leader>sg` | search text in the project |
| `<leader>sw` | search the word under the cursor |
| `<leader>sb` | open buffers |
| `<leader>sh` | help pages |
| `<leader>sd` | all diagnostics |
| `<leader>sr` | reopen the last search |
| `<leader>a` / `<leader>h` | harpoon: mark this file / list marked files |
| `<leader>1`…`4` | harpoon: jump to marked file 1–4 |
| `<leader>p` / `<leader>n` | harpoon: previous / next marked file |
| `<leader>u` | undo tree |

In a picker: `Ctrl+s` / `Ctrl+v` open in a split / vertical split, `Alt+q` sends the results to the quickfix list.

### Code

| key | does |
| --- | --- |
| `gd` | go to definition |
| `K` | docs for the symbol under the cursor |
| `grn` | rename |
| `gra` | code action |
| `grr` / `gri` / `grt` | references / implementations / type definition |
| `gO` | symbols in this file |
| `[d` / `]d` | previous / next diagnostic |
| `<leader>e` | full diagnostic message for this line |
| `<leader>f` | format file (or selection) |
| `<leader>ss` | steplink: step ↔ step definition (in `.feature` and `steps/` files) |
| `<` / `>` (visual) | indent, keeping the selection |

Completion menu: `Ctrl+n` / `Ctrl+p` move, `Ctrl+y` accept, `Ctrl+e` close, `Ctrl+Space` open / show docs, `Ctrl+b` / `Ctrl+f` scroll docs, `Tab` / `Shift+Tab` jump inside a snippet. In insert mode, `Ctrl+s` shows the function signature.

### Git

| key | does |
| --- | --- |
| `]h` / `[h` | next / previous change |
| `<leader>ga` | stage the change (again to unstage); in visual mode: the selected lines |
| `<leader>gr` | reset the change; in visual mode: the selected lines |
| `<leader>gA` / `<leader>gR` | stage / reset the whole file |
| `<leader>gp` | preview the change |
| `<leader>gd` | diff the file against the staged version |
| `<leader>gb` | blame this line (full commit) |
| `<leader>gB` | inline blame on / off |
| `<leader>gs` | git status (picker) |
| `ih` | the change as a text object: `vih` selects it, `dih` deletes it |

### Commands

`:PackUpdate` update plugins (`:w` applies, `:q` cancels) · `:PackDel <name>` remove a plugin ·
`:Hardtime toggle` / `:Hardtime report` · `:StepLinkOrphans` unused step definitions ·
`:checkhealth` · `:Mason`

## tmux

| key | does |
| --- | --- |
| `Ctrl+h/j/k/l` | move between panes (and Neovim splits) |
| `prefix` `Ctrl+l` | clear the screen (since `Ctrl+l` moves) |
| `prefix` `h/j/k/l` | move between panes |
| `prefix` `H/J/K/L` | resize the pane (hold to repeat) |
| `prefix` `"` / `%` | split below / to the right, in the current folder |
| `prefix` `c` | new window, in the current folder |
| `prefix` `f` | fuzzy-pick a session or window |
| `prefix` `1`…`9` / `n` / `p` | go to window / next / previous |
| `prefix` `z` | zoom the pane (toggle) |
| `prefix` `x` / `&` | close the pane / window |
| `prefix` `,` / `$` | rename the window / session |
| `prefix` `w` / `s` | list windows / sessions |
| `prefix` `d` | detach (tmux keeps running) |
| `prefix` `Ctrl+s` / `Ctrl+r` | save / restore sessions (also saved every 15 min) |
| `prefix` `r` | reload the config |
| `prefix` `I` / `U` | install / update tmux plugins |
| `prefix` `:` | tmux command prompt (Vim keys) |
| `prefix` `?` | all keys |

Copy mode (`prefix` `[`, or scroll up with the mouse): move with Vim keys, `v` select, `Ctrl+v` block select,
`y` copy to the system clipboard, `q` quit. `prefix` `P` pastes. Dragging with the mouse copies too.

## zsh

| key | does |
| --- | --- |
| `Esc` | normal mode (Vim motions: `w` `b` `e` `0` `$` `f`, `ciw`, `dd`, `u`…); `i` / `a` to type again |
| `v` then `v` | open the command in Neovim (`:wq` runs it) |
| `Ctrl+y` or `→` | accept the grey suggestion |
| `Ctrl+r` | search history (fzf) |
| `Ctrl+t` | insert a file path (fzf) |
| `Alt+c` | cd into a folder (fzf) |
| `Tab` | completion menu (arrow keys / Tab to pick) |

The cursor shows the mode: a bar while typing, a block in normal mode. Typing a folder name on its own cds into it.
`zsh-plugins-update` updates the zsh plugins (`install.sh update` does this too).

## kitty

| key | does |
| --- | --- |
| `Ctrl+click` | open a link (also inside tmux) |
| `Shift` + drag | select with kitty instead of tmux (inside tmux); selecting copies |
| `Ctrl+Shift+c` / `v` | copy / paste (macOS: `Cmd+c` / `v`) |
| `Ctrl+Shift+=` / `-` / `Backspace` | font bigger / smaller / reset (macOS: `Cmd+=` / `-` / `0`) |
| `Ctrl+Shift+F5` | reload the config (macOS: `Cmd+Ctrl+,`) |
