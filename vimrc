" Minimal Vim configuration for a-Shell. Uses Vim built-ins only.
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
set laststatus=0 showmode
set swapfile writebackup nobackup
if exists('+signcolumn') | set signcolumn=auto | endif
if has('clipboard') | set clipboard=unnamedplus | endif
if has('termguicolors') | set termguicolors | endif
set background=dark

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

" Vim's built-in colours with a transparent editor and subdued UI.
colorscheme default
highlight Normal guibg=NONE ctermbg=NONE
highlight NormalNC guibg=NONE ctermbg=NONE
highlight NormalFloat guibg=NONE ctermbg=NONE
highlight LineNr guifg=#777777 guibg=NONE ctermfg=8 ctermbg=NONE
highlight SignColumn guifg=#777777 guibg=NONE ctermfg=8 ctermbg=NONE
highlight EndOfBuffer guifg=#555555 guibg=NONE ctermfg=8 ctermbg=NONE
highlight VertSplit guifg=#555555 guibg=NONE ctermfg=8 ctermbg=NONE

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

set wildignore+=*/.git/*,*/node_modules/*,*/.venv/*,*/__pycache__/*,*/dist/*,*/build/*

augroup ashell_vim
  autocmd!
  autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line('$') | execute 'normal! g`"' | endif
augroup END
