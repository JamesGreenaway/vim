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
| Theme | vim-code-dark (dark palette with limited-color terminal support) |
| Statusline | Mode, filename, modified/read-only flags, file type, cursor and position |
| Format on save | Synchronous LSP formatting when a running server supports it |
| Recovery | Persistent undo, swap files and write-time backup protection |

Theme: `vim-code-dark`, selected for a dark VS Code-like palette and support for both 256-color and 8/16-color terminals. The config does not force terminal colors to truecolor. Fuzzy finders and Treesitter remain omitted; fzf hung Vim on the device.

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
| Statusline | Mode, filename, file type, cursor position and modified marker |
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

## LSP and formatting: install, then verify on device

The Vim LSP client is installed. It registers the following commands only when
Vim can find them on `PATH`:

| Files | Server command | Status |
|---|---|---|
| JavaScript, JSX, TypeScript, TSX | `typescript-language-server --stdio` | Install with npm; a-Shell process compatibility needs checking |
| HTML | `vscode-html-language-server --stdio` | Install with npm; a-Shell process compatibility needs checking |
| CSS | `vscode-css-language-server --stdio` | Install with npm; a-Shell process compatibility needs checking |
| JSON | `vscode-json-language-server --stdio` | Install with npm; a-Shell process compatibility needs checking |
| Python | `ruff server` | Ruff 0.17.0 is already present on your device; test the embedded LSP |
| C/C++ | `clangd` | Missing on the device; a-Shell compatible build not confirmed |
| GLSL | — | Syntax highlighting is working via your installed `vim-glsl`; no GLSL LSP configured |

Install the npm-based servers from a-Shell:

```sh
npm install -g typescript typescript-language-server vscode-langservers-extracted
```

Then check they are visible to Vim:

```sh
which typescript-language-server
which vscode-html-language-server
which vscode-css-language-server
which vscode-json-language-server
ruff --version
```

Your installed Ruff includes a native LSP (`ruff server`) that provides diagnostics
and formatting. It does not provide Python navigation or completion on its own.
The TypeScript server provides JavaScript/TypeScript language intelligence; HTML,
CSS and JSON servers provide their corresponding language features. The npm
commands above are the standard server entry points, but a-Shell's embedded Node
and iOS process handling still need a live test. `clang` does not include `clangd`,
and a usable iOS clangd install is not confirmed.

Open a `.ts`, `.py`, `.html`, `.css`, or `.json` file and run:

```vim
:AshellLspStatus
:LspStatus
```

The first command reports whether Vim can find each server command. The second
reports whether the LSP client has actually started a server for the current
buffer. Then try `gd` on a known symbol and `K` for hover. A successful save alone
does not prove formatting ran: test a deliberately misformatted snippet and
inspect the saved bytes. Formatting only runs when an attached server advertises
formatting support; if none does, the save proceeds normally.

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

The colorscheme has 256-color and 8/16-color support; `termguicolors` is enabled when Vim reports the feature. Persistent state is under `.vim/state` in Documents, avoiding a-Shell's unwritable home directory.

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
