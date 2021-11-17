syntax on
filetype plugin indent on
set confirm
set encoding=utf-8
set autoindent
set nowrap
set softtabstop=2
set tabstop=2
set shiftwidth=2
set backspace=2 
set cursorline
set hidden "Allow more than one unsaved buffer
set list "Show invisible characters by default
set switchbuf=usetab,newtab "If a bffer is already open in a window in any tab, switch to that tab/window < https://stackoverflow.com/a/3476411/278810 >
set wildmode=longest:full,full
set wildmenu
set wildignore=*.o,*~
set wildignorecase

" allow mouse jumps
set ttyfast
set mouse=a

" Line numbers
set number relativenumber
augroup relnum_focus
	autocmd! FocusLost,InsertEnter * if &number | setl norelativenumber | else | echom "Line numbers hidden" | endif
	autocmd! FocusGained,InsertLeave * if &number | setl relativenumber | else | echom "Line numbers hidden" | endif
augroup END

function ToggleLineNumbers()
	set number!
	set relativenumber!
endfunction

if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif


"OS-Specific {{{

"Fallback for detecting the OS
if !exists('g:os')
  if has('win32') || has('win16')
    let g:os = 'Windows'
  else
    let g:os = substitute(system('uname'), '\n', '', '')
  endif
endif

"if g:os == 'Darwin'
"endif

"if g:os == 'Linux'
"endif

"if g:os == 'Windows'
"endif

"}}}

