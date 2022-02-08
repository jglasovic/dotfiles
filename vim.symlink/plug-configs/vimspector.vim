let g:vimspector_enable_mappings = 'HUMAN'

let g:vimspector_install_gadgets = [ 'debugpy', 'debugger-for-chrome' ]

function GetExecName()
  let s:mapper = {
        \ 'python': 'python',
        \ 'javascript': 'node',
        \ 'typescript': 'node',
        \ 'javascriptreact': 'node',
        \ 'typescriptreact': 'node'
        \ }

  return get(s:mapper, &filetype, '')
endfunction



function! CustomAttachDebugger()
  let workspaces = get(g:, 'WorkspaceFolders', [])
  let file_location = expand('%:p')
  let vscode_dir = ''

  while len(workspaces) > 0 && index(workspaces, file_location) == -1 && vscode_dir == ''
    let file_location = trim(system('dirname '. file_location), 0)
    let vscode_dir = trim(system('find ' . file_location . ' -maxdepth 1 -name .vscode'), 0)
  endwhile

  if vscode_dir != ''
    let launch_json_file_path = vscode_dir . "/launch.json"

    if filereadable(launch_json_file_path)
      let data = trim(system('npx json5 '. launch_json_file_path))
      let vscode_launch = json_decode(data)
      let vscode_configurations = get(vscode_launch, 'configurations', [])
      for vs_config in vscode_configurations
        let request = get(vs_config, 'request', '')
        let config = {}
        let variables = {}
        if request == 'attach'
          let connection = get(vs_config, 'connect', {})
          let port = get(connection, 'port', '')
          if port == ''
            let port = get(vs_config, 'port', '')
          endif
          let host = get(connection, 'host', 'localhost')
          if exists('vs_config.connect')
            unlet vs_config.connect
          endif
          let variables = {"host": host, "port": port}
          let config = vs_config
        endif

        let vimspect_config = {
            \ "Launch Debugger": {
            \   "adapter": "multi-session",
            \   "variables": variables,
            \   "configuration": config,
            \   "breakpoints": {"exception": {"raised": "N", "uncaught": "", "userUnhandled": ""}},
            \ }
            \ }
        echom vimspect_config
        call vimspector#LaunchWithConfigurations(vimspect_config)
      endfor
    endif

  else
    echo "No .vscode debug configuration file"
  endif
 endfunction
