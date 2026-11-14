# Vim for a-Shell

A small Vim configuration based on [JamesGreenaway/neovim](https://github.com/JamesGreenaway/neovim), adapted for a-Shell on iPhone/iPad.

## Install

In a-Shell:

```sh
cd ~/Documents
lg2 clone https://github.com/JamesGreenaway/vim.git
cd vim
python3 install.py
```

Restart Vim, then run:

```vim
:helptags ALL
:AshellHealth
```

Python downloads the pinned plugins over HTTPS. No vim-plug, desktop Git, Node or
language-server installation is needed for the base editor. The installer backs
up an existing `~/Documents/.vimrc` beside it before replacing it. Re-running is
safe: matching pinned packages are reused; conflicting packages are not overwritten.

If you already have a `~/Documents/vim` checkout, use `lg2 pull` there, then rerun
the installer. To uninstall, restore the timestamped `.vimrc.before-ashell-*`
backup (or remove the new .vimrc if there was none). The optional packages under
`.vim/pack/ashell/opt` are only loaded when requested by the configuration.

## Included

| Feature | Implementation |
|---|---|
| File browser | Built-in netrw, full-width |
| Commenting | tpope/vim-commentary (`gcc`, `gc`) |
| Surrounding text | tpope/vim-surround (`cs`, `ds`, `ys`) |
| Bracket/quote pairing | jiangmiao/auto-pairs |
| Project indentation | editorconfig/editorconfig-vim |
| LSP client | prabirshrestha/vim-lsp |
| Automatic completion | asyncomplete.vim + asyncomplete-lsp.vim |
| Format on save | Synchronous LSP formatting when a running server supports it |
| Recovery | Persistent undo, swap files and write-time backup protection |

No theme, fuzzy finder, Treesitter, Git UI, debugger, Herdr or embedded-terminal
configuration. fzf was explicitly excluded after it hung Vim on the device.
No replacement fuzzy-finder plugin is installed.

## Key bindings

Space is the leader.

| Keys | Action |
|---|---|
| Space w / q / x | Save / quit window / delete buffer |
| Space Tab / Shift-Tab | Next / previous buffer |
| Space bn / bp | Next / previous buffer without modifier keys |
| Space fb | List buffers and prefill `:buffer` |
| Space e | Full-width netrw |
| Space - / backslash | Horizontal / vertical split |
| Ctrl-h/j/k/l | Navigate splits |
| jj or jk | Leave insert mode |
| Escape (normal mode) | Clear search highlighting |
| Space tw | Toggle wrapping |
| Space fg | Prefill `:ProjectSearch` |
| Space fh | Prefill `:help` |
| Space f= | Format using the active LSP |
| gcc / gc{motion} | Comment line / motion (also gc in visual mode) |
| cs / ds / ys | Change / delete / add surroundings |

When an LSP attaches:

| Keys | Action |
|---|---|
| gd / grr / gri | Definition / references / implementation |
| grn / gra / gO | Rename / code action / document symbols |
| K | Hover documentation |
| [d / ]d | Previous / next diagnostic |
| Ctrl-X Ctrl-O | Manual completion |
| Ctrl-N / Ctrl-P / Ctrl-Y | Next / previous / accept completion |

`ProjectSearch` searches literal text under the current working directory using
Vim's synchronous `:vimgrep`; use `:cd` to select a small project first. Common
build/dependency directories are excluded. It is not live grep. Space x uses
ordinary `:bdelete`, not the Neovim split-preserving workaround.

## LSP and formatting: prepared, not yet verified on device

The client and completion plugins are installed. The config registers these
servers **only if their commands exist**:

| Language | Command |
|---|---|
| JavaScript/TypeScript | `typescript-language-server --stdio` |
| Python | `pylsp` |
| Go | `gopls` |
| C/C++ | `clangd` |

No server is downloaded automatically. These are registration recipes, not a
claim that all four servers can run inside iOS. Native desktop executables cannot
simply be copied into a-Shell. The availability of Node does not prove that a
server's child processes work there; clang is not clangd. Python server failures
have also been reported upstream.

In an actual source file, use `:LspStatus`, then test completion and definition.
A running server must advertise document formatting for format-on-save to apply.
If no suitable server is running, saving proceeds without formatting. Formatting
errors from the plugin are shown in `:messages`; a successful save alone is not
proof of successful formatting. Python's pylsp additionally needs a supported
formatting provider. Ruff is present on the device but is not automatically used
as an untested LSP or shell formatter.

Create `~/Documents/.vim/local.vim` for overrides. It is not touched by installation
and is loaded before packages. Example with your own verified server:

```vim
let g:ashell_servers = [
      \ {'name': 'typescript',
      \  'cmd': ['typescript-language-server', '--stdio'],
      \  'allowlist': ['javascript', 'javascriptreact', 'typescript', 'typescriptreact']},
      \ ]
```

To disable automatic formatting, add:

```vim
let g:ashell_format_on_save = 0
```

## Compatibility record

User-reported on-device results:

- fzf 0.74.5 (embedded iOS); invoking it from Vim hung the editor, so omitted.
- ripgrep 15.2.0 without PCRE2; Node 26.12.1; npm 11.20.0; Ruff 0.17.0.
- Vim: jobs yes, channels yes, terminal no, popup windows yes.

`:AshellHealth` writes `~/Documents/ashell-vim-health.txt`. Feature flags and
executable discovery do not prove working iOS communication. Remaining device
checks: clipboard round-trip with Notes, undo after reopening a file, pairing on
the iOS keyboard, LSP operation and actual formatted bytes after saving.

No theme or forced true colour. Persistent state is under `.vim/state` in
Documents, avoiding a-Shell's unwritable home directory.

## Validation

The installer and Vim startup/editing checks are tested on Linux Vim; this does
not qualify a-Shell's runtime or its language servers. See `tests/smoke.vim`.

```sh
python3 install.py --target "$PWD/.test-install"
vim -Nu .test-install/.vimrc -i NONE -n -es -S tests/smoke.vim
```

Upstream references:

- [a-Shell Vim configuration guide](https://bianshen00009.gitbook.io/a-guide-to-a-shell/basic-tutorials/configure-your-vim)
- [vim-lsp](https://github.com/prabirshrestha/vim-lsp)
- [a-Shell Python LSP discussion](https://github.com/holzschu/a-shell/discussions/885)
