" use tmux pane to run test if inside tmux
if exists('$TMUX')
  let test#strategy = "vimux"
  let g:VimuxOrientation = "h"
  let g:VimuxHeight = "50"
endif

let test#neovim#term_position = "vert"
let test#vim#term_position = "vert"
let g:test#transformation = 'custom'

" when working with monorepo, workspaces or file opened explicitly with vim, 
" dynamicly sets project root dir based on coc#util#root_patterns
function! s:run_before()
  if !test#exists()
    throw "Not a test file!"
  endif
  let g:test#project_root = utils#get_root_dir()
endfunction

" transforming all test cmd to cd into the proper root for exec
function! SetupTestRoot(cmd)
  return "cd ".shellescape(g:test#project_root)." ; ".a:cmd." ; cd -"
endfunction

let g:test#custom_transformations = {'custom': function('SetupTestRoot')}

nmap <silent> <leader>tt :call <SID>run_before() \| TestNearest<CR>
nmap <silent> <leader>tT :call <SID>run_before() \| TestFile<CR>
nmap <silent> <leader>ta :call <SID>run_before() \| TestSuite<CR>
" test last can be exec from anywhere so no need to pre setup anything, vim-test handles that
nmap <silent> <leader>t_ :TestLast<CR> 

" nmap <silent> <leader>td :call DebugNearest()<CR>
" function! DebugNearest()
"   let g:test#transformation = 'debug'
"   call RunTestWrapper('TestNearest')
"   let g:test#transformation = 'all'
"   echom "==============="
"   call vimspector#Reset()
" endfunction
"
" " run nearest test with vimspector
" let s:host = 'localhost'
" let s:port = 5678

" function! StartDebuger(timer)
"   call vimspector#LaunchWithSettings(#{ 
"    \ configuration: 'attach', 
"    \ port: s:port,
"    \ host: s:host })
" endfunction

" function! DebugTransform(cmd) abort
"   let runner = test#determine_runner(expand('%'))
"   if !has_key(g:test_runner_debugger_mapping, runner)
"     throw "No debugger configuration set for runner: ".runner
"   endif
"   call timer_start(500, function('StartDebuger'))
"   let command = AllTransform(g:test_runner_debugger_mapping[runner](a:cmd))
"   return command
" endfunction      

" """ Debug Runners transform - only ever need to update this for new runners
" " ==========================
" function! Pytest(cmd)
"   let debugger = "python -m debugpy --listen ".s:host.":".s:port." --wait-for-client -m pytest"
"   return substitute(a:cmd, 'pytest', debugger, '')
" endfunction

" " TODO: add jest

" let g:test_runner_debugger_mapping = {
"     \ "python#pytest": function('Pytest') 
"     \ }

" ==========================




