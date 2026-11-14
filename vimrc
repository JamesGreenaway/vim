" James's a-Shell Vim configuration. No Neovim APIs.
set nocompatible
let mapleader = ' '
let s:config = resolve(expand('<sfile>:p'))
let s:base = fnamemodify(s:config, ':h')
let s:vimdir = s:base . '/.vim'
execute 'set runtimepath^=' . fnameescape(s:vimdir)
execute 'set packpath^=' . fnameescape(s:vimdir)
filetype plugin indent on
syntax enable
set hidden number norelativenumber nowrap
set expandtab shiftwidth=2 softtabstop=2 tabstop=2
set ignorecase smartcase incsearch hlsearch
set wildmenu wildmode=longest:full,full
set completeopt=menu,menuone,noselect
set scrolloff=3 sidescrolloff=3 splitbelow splitright
set nojoinspaces virtualedit=block
set laststatus=2
set statusline=%{toupper(strpart(mode(),0,1))}\ %t%h%r%m%=%y\ %l:%c\ %p%%
set swapfile writebackup nobackup
if exists('+signcolumn') | set signcolumn=auto | endif
if has('clipboard') | set clipboard=unnamedplus | endif
" Dark theme uses cterm colors when truecolor is unavailable.
if has('termguicolors') | set termguicolors | endif
let g:codedark_modern = 1
for s:kind in ['undo', 'swap', 'backup']
  call mkdir(s:vimdir . '/state/' . s:kind, 'p', 0700)
endfor
let &directory = s:vimdir . '/state/swap//'
let &backupdir = s:vimdir . '/state/backup//'
if has('persistent_undo')
  let &undodir = s:vimdir . '/state/undo//'
  set undofile
endif
let &viminfofile = s:vimdir . '/state/viminfo'
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 0
nnoremap <leader>w :write<CR>
nnoremap <leader>q :quit<CR>
nnoremap <leader>x :bdelete<CR>
nnoremap <leader><Tab> :bnext<CR>
nnoremap <leader><S-Tab> :bprevious<CR>
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <Esc> :nohlsearch<CR>
inoremap jk <Esc>
inoremap jj <Esc>
nnoremap <leader>e :Explore<CR>
nnoremap <leader>- :split<CR>
nnoremap <leader>\ :vsplit<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <leader>tw :setlocal wrap! wrap?<CR>
nnoremap <leader>fb :buffers<CR>:buffer<Space>
nnoremap <leader>fh :help<Space>
nnoremap <leader>fg :ProjectSearch<Space>
" Literal search in cwd; synchronous, not Telescope live grep.
function! s:Search(text) abort
  if empty(a:text) | return | endif
  try
    execute 'vimgrep /\V' . escape(a:text, '\/') . '/gj **/*'
    copen
  catch /^Vim\%((\a\+)\)\=:E480/
    echo 'No matches'
  endtry
endfunction
command! -nargs=+ ProjectSearch call <SID>Search(<q-args>)
set wildignore+=*/.git/*,*/node_modules/*,*/.venv/*,*/__pycache__/*,*/dist/*,*/build/*
" Avoid Alt shortcuts on the iOS keyboard.
let g:AutoPairsShortcutToggle = ""
let g:AutoPairsShortcutFastWrap = ""
let g:AutoPairsShortcutJump = ""
let g:AutoPairsShortcutBackInsert = ""
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_format_sync_timeout = 2000
let g:ashell_format_on_save = 1
let g:ashell_servers = [
      \ {'name': 'typescript', 'cmd': ['typescript-language-server', '--stdio'], 'allowlist': ['javascript', 'javascriptreact', 'typescript', 'typescriptreact']},
      \ {'name': 'html', 'cmd': ['vscode-html-language-server', '--stdio'], 'allowlist': ['html']},
      \ {'name': 'css', 'cmd': ['vscode-css-language-server', '--stdio'], 'allowlist': ['css', 'scss', 'less']},
      \ {'name': 'json', 'cmd': ['vscode-json-language-server', '--stdio'], 'allowlist': ['json', 'jsonc']},
      \ {'name': 'ruff', 'cmd': ['ruff', 'server'], 'allowlist': ['python']},
      \ {'name': 'clangd', 'cmd': ['clangd'], 'allowlist': ['c', 'cpp']},
      \ ]
" Override servers/options here before packages load. Installing a client does
" not install servers or prove that iOS can execute them.
if filereadable(s:vimdir . '/local.vim')
  execute 'source ' . fnameescape(s:vimdir . '/local.vim')
endif
function! s:RegisterServers() abort
  for server in g:ashell_servers
    if executable(server.cmd[0])
      call lsp#register_server(server)
    endif
  endfor
endfunction
function! s:LspEnabled() abort
  setlocal omnifunc=lsp#complete
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> grr <plug>(lsp-references)
  nmap <buffer> gri <plug>(lsp-implementation)
  nmap <buffer> grn <plug>(lsp-rename)
  nmap <buffer> gra <plug>(lsp-code-action)
  nmap <buffer> gO <plug>(lsp-document-symbol-search)
  nmap <buffer> K <plug>(lsp-hover)
  nmap <buffer> [d <plug>(lsp-previous-diagnostic)
  nmap <buffer> ]d <plug>(lsp-next-diagnostic)
endfunction
function! s:Format() abort
  if !exists('*lsp#get_allowed_servers') | return | endif
  for server in lsp#get_allowed_servers()
    if lsp#get_server_status(server) ==# 'running' && lsp#capabilities#has_document_formatting_provider(server)
      call lsp#internal#document_formatting#format({"bufnr": bufnr("%"), "server": server, "sync": 1})
      return
    endif
  endfor
endfunction
command! Format call <SID>Format()
nnoremap <leader>f= :Format<CR>
augroup ashell_vim
  autocmd!
  autocmd User lsp_setup call <SID>RegisterServers()
  autocmd User lsp_buffer_enabled call <SID>LspEnabled()
  autocmd BufWritePre * if g:ashell_format_on_save && &buftype ==# '' | call <SID>Format() | endif
  autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line('$') | execute 'normal! g`"' | endif
augroup END
if has('packages')
  packadd vim-commentary
  packadd auto-pairs
  packadd vim-surround
  packadd editorconfig-vim
  packadd vim-code-dark
  colorscheme codedark
  if has('job') && has('channel')
    packadd vim-lsp
    packadd asyncomplete.vim
    packadd asyncomplete-lsp.vim
  endif
endif
function! s:Health() abort
  let report = ['a-Shell Vim compatibility report', 'Vim version: ' . v:version, 'Config: ' . s:config, 'State: ' . s:vimdir . '/state']
  for feature in ['packages', 'job', 'channel', 'terminal', 'timers', 'popupwin', 'textprop', 'clipboard', 'termguicolors', 'persistent_undo', 'python3']
    call add(report, feature . ': ' . has(feature))
  endfor
  for server in g:ashell_servers
    call add(report, server.name . ' executable: ' . executable(server.cmd[0]))
  endfor
  call add(report, 'Executable presence is not a server startup test. Open its file type and use :LspStatus.')
  call add(report, 'Clipboard and colour require visual/device checks; feature flags alone are insufficient.')
  call add(report, 'Fuzzy finders and Treesitter deliberately omitted; fzf hung Vim on device.')
  let reportfile = s:base . '/ashell-vim-health.txt'
  call writefile(report, reportfile)
  echo join(report, "\n")
  echo 'Saved: ' . reportfile
endfunction
command! AshellHealth call <SID>Health()
function! s:LspStatus() abort
  let report = ['LSP commands (availability only):']
  for server in g:ashell_servers
    call add(report, server.name . ': ' . (executable(server.cmd[0]) ? 'found' : 'not found') . ' — ' . join(server.cmd, ' '))
  endfor
  call add(report, 'Open a matching source file, then run :LspStatus to check whether the server starts.')
  echo join(report, "\n")
endfunction
command! AshellLspStatus call <SID>LspStatus()
