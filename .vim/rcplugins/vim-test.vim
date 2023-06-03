" use tmux pane to run test if inside tmux
if exists('$TMUX')
  let g:test#strategy = "vimux"
  let g:VimuxOrientation = "h"
  let g:VimuxHeight = "50"
endif

let g:test#neovim#term_position = "vert"
let g:test#vim#term_position = "vert"
let g:test#transformation = 'custom'
let g:test_debug_port = 5678

" when working with monorepo, workspaces or file opened explicitly with vim, 
" dynamicly sets project root dir based on LSP workspace
function! s:run_before(...) abort
  if !test#exists()
    throw "Not a test file!"
  endif
  let g:test#project_root = utils#get_root_dir()
endfunction

" transforming all test cmd to cd into the proper root for exec
function SetupTest(cmd) abort
  let cmd = a:cmd
  if stridx(cmd, '--debug') != -1
    let cmd = substitute(cmd, ' --debug', '', 'g')
    let [language, runner] = split(test#determine_runner(expand('%')), '#')
    if !has_key(g:test_runner_debugger_mapping, runner)
      throw "Missing debug configuration for runner: ".runner
    endif
    let cmd = substitute(cmd, runner, g:test_runner_debugger_mapping[runner], 'g')
  endif
  return "cd ".shellescape(g:test#project_root)." ; ".cmd." ; cd -"
endfunction

" test runner mappings
let g:test_runner_debugger_mapping = {
    \ "pytest": "python -m debugpy --listen ".g:test_debug_port." --wait-for-client -m pytest --no-cov -s",
    \ "jest": ""
    \ }
"===========================


let g:test#custom_transformations = { 'custom': function('SetupTest') } 

nmap <silent> <leader>tt :call <SID>run_before() \| TestNearest<CR>
nmap <silent> <leader>tT :call <SID>run_before() \| TestFile<CR>
nmap <silent> <leader>ta :call <SID>run_before() \| TestSuite<CR>
" test last can be exec from anywhere so no need to pre setup anything, vim-test handles that
nmap <silent> <leader>t_ :TestLast<CR> 

if has('nvim') && type(luaeval("require'dap'.run")) == v:t_func " use nvim-dap to debug tests
  nmap <silent> <leader>dtt :call <SID>run_before() \| TestNearest --debug \| RunTestDebugger<CR>
  nmap <silent> <leader>dtT :call <SID>run_before() \| TestFile --debug    \| RunTestDebugger<CR>
  nmap <silent> <leader>dta :call <SID>run_before() \| TestSuite --debug   \| RunTestDebugger<CR>
endif
