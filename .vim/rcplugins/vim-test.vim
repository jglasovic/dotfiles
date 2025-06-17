" use tmux pane to run test if inside tmux
if exists('$TMUX')
  let g:test#strategy = "vimux"
  let g:VimuxOrientation = "h"
  let g:VimuxHeight = "50%"
endif

let g:test#neovim#term_position = "vert"
let g:test#vim#term_position = "vert"
let g:test#transformation = 'custom'
let g:test_debug_port = 5678
"let g:test#echo_command = 0

" when working with monorepo, workspaces or file opened explicitly with vim, 
" dynamicly sets project root dir based on LSP workspace
let g:test#project_root = function('utils#get_root_dir')

" transforming all test cmd to cd into the proper root for exec
function SetupTest(cmd) abort
  let cmd = a:cmd
  " support debugger 
  let attach_debugger = stridx(cmd, '--debug') != -1
  if attach_debugger
    let cmd = substitute(cmd, ' --debug', '', 'g')
  endif

  " find runner
  let [language, runner] = split(test#determine_runner(expand('%')), '#')
  if attach_debugger && !has_key(g:test_runner_debugger_mapping, runner)
    throw "Missing debug configuration for runner: ".runner
  endif
  let SetupCmd = get(g:test_runner_debugger_mapping, runner, v:false)
  if SetupCmd == v:false
    return cmd
  endif
  let cmd = SetupCmd(cmd, attach_debugger)
  let project_root = utils#get_root_dir()
  let command = "cd ".shellescape(project_root)." ; ".cmd." ; cd -"
  if attach_debugger
    exec "AttachDebugger ".g:test_debug_port
  endif
  return command
endfunction

" test runner mappings
function s:setup_pytest(cmd, attach_debugger)
  if a:attach_debugger
    let debug_cmd = "python -m debugpy --listen ".g:test_debug_port." --wait-for-client -m pytest --log-level=DEBUG --no-cov -vv -s "
    return substitute(a:cmd, "pytest", debug_cmd, 'g')
  endif
  return a:cmd
endfunction


function s:setup_jest(cmd, attach_debugger)
  let jest_bin = 'node_modules/.bin/jest'
  let jest_bin_path = jest_bin
  try
    let jest_bin_dir  = utils#get_root_dir({'patterns': [jest_bin]})
    let jest_bin_path = jest_bin_dir ."/". jest_bin
  endtry
  let debug_cmd = jest_bin_path." --runInBand "
  if a:attach_debugger
    let debug_cmd = "node --inspect-brk=".g:test_debug_port." ".jest_bin_path." --runInBand "
  endif
  if a:cmd =~# jest_bin
    return substitute(a:cmd, jest_bin, debug_cmd, 'g')
  endif
  return substitute(a:cmd, 'jest', debug_cmd, 'g')
endfunction

let g:test_runner_debugger_mapping = {
      \ "pytest": function('s:setup_pytest'),
      \ "jest": function('s:setup_jest')
      \ }
"===========================


let g:test#custom_transformations = { 'custom': function('SetupTest') } 

nmap <silent> <leader>tt :TestNearest<CR>
nmap <silent> <leader>tT :TestFile<CR>
nmap <silent> <leader>ta :TestSuite<CR>

if has('nvim') && luaeval("pcall(require, 'dap')") " use nvim-dap to debug tests
  nmap <silent> <leader>dtt :TestNearest --debug<CR>
  nmap <silent> <leader>dtT :TestFile --debug<CR>
  nmap <silent> <leader>dta :TestSuite --debug<CR>
endif

" test last can be exec from anywhere so no need to pre setup anything, vim-test handles that
nmap <silent> <leader>t_ :TestLast<CR> 

