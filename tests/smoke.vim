" Run after install.py --target "$PWD/.test-install" from the repository root.
call assert_equal('', v:errmsg)
call assert_equal(' ', g:mapleader)
call assert_equal(2, exists(':Commentary'))
call assert_true(exists('g:loaded_surround'))
call assert_true(exists('g:AutoPairsLoaded'))
call assert_equal(2, exists(':LspStatus'))
call assert_equal(0, exists(':CtrlP'))
call assert_equal(0, exists(':FZF'))
call assert_equal('', maparg('<leader>ff', 'n'))
call assert_equal(3, &scrolloff)
call assert_equal(1, &writebackup)
call assert_equal(1, &undofile)
call assert_equal('menu,menuone,noselect', &completeopt)
new
setlocal filetype=python
call setline(1, 'print("hello")')
normal gcc
call assert_match('^#', getline(1))
normal gcc
call assert_equal('print("hello")', getline(1))
call setline(1, '"hello"')
normal cs"'
call assert_equal("'hello'", getline(1))
call setline(1, '')
call feedkeys("i(\<Esc>", 'xt')
call assert_equal('()', getline(1))
" No server must not block saving or modify text.
execute 'file ' . fnameescape(getcwd() . '/.test-install/smoke.py')
write!
call assert_equal(['()'], readfile('.test-install/smoke.py'))
AshellHealth
call assert_true(filereadable('.test-install/ashell-vim-health.txt'))
if !empty(v:errors)
  call writefile(v:errors, '.test-install/errors.txt')
  cquit
endif
qa!
