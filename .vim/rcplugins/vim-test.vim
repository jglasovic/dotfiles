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
  let attach_debugger = v:false
  if stridx(cmd, '--debug') != -1
    let attach_debugger = v:true
    let cmd = substitute(cmd, ' --debug', '', 'g')
    let [language, runner] = split(test#determine_runner(expand('%')), '#')
    if !has_key(g:test_runner_debugger_mapping, runner)
      throw "Missing debug configuration for runner: ".runner
    endif
    let mapping = g:test_runner_debugger_mapping[runner]
    let cmd = substitute(cmd, mapping["replace"], mapping["cmd"], 'g')
  endif
  let project_root = utils#get_root_dir()
  let command = "cd ".shellescape(project_root)." ; ".$TEST_PREFIX_CMD." ".cmd." ; cd -"
  if attach_debugger
    exec "AttachDebugger ".g:test_debug_port
  endif
  return command
endfunction

" test runner mappings
let g:test_runner_debugger_mapping = {
      \ "pytest": { 
      \   "cmd": "python -m debugpy --listen ".g:test_debug_port." --wait-for-client -m pytest --log-level=DEBUG --no-cov -vv -s ",
      \   "replace": "pytest"
      \ },
      \ "jest": {
      \   "cmd": "node --inspect-brk=".g:test_debug_port." node_modules/.bin/jest --runInBand ",
      \   "replace": "node_modules/.bin/jest"
      \ }
      \ }
"===========================


let g:test#custom_transformations = { 'custom': function('SetupTest') } 

nmap <silent> <leader>tt :TestNearest<CR>
nmap <silent> <leader>tT :TestFile<CR>
nmap <silent> <leader>ta :TestSuite<CR>
" test last can be exec from anywhere so no need to pre setup anything, vim-test handles that
nmap <silent> <leader>t_ :TestLast<CR> 

if has('nvim') && type(luaeval("require'dap'.run")) == v:t_func " use nvim-dap to debug tests
  nmap <silent> <leader>dtt :TestNearest --debug<CR>
  nmap <silent> <leader>dtT :TestFile --debug<CR>
  nmap <silent> <leader>dta :TestSuite --debug<CR>
endif
