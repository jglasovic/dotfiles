if !executable('gh')
  finish
endif

function! s:sync_base_branch(base_ref)
  let base = a:base_ref
  call system("git fetch origin ".base)
  if !v:shell_error
    return base
  endif
  " could be that the base branch has been renamed, try current default branch
  let output = systemlist("gh repo view --json 'defaultBranchRef' | jq -r '.defaultBranchRef.name'")
  if v:shell_error 
    throw "Cannot find base branch origin ".base
  endif
  "update the base and try again
  let [base] = output
  call system("git fetch origin ".base)
  if v:shell_error
    throw "Error fetching origin ".base
  endif
  return base
endfunction

function! s:sync_ref_branch(head_ref, pr_number)
  let ref = a:head_ref
  let pr_number = a:pr_number
  "try fetch origin head
  call system("git fetch origin ".ref)
  if !v:shell_error 
    return [ref, "origin/".ref]
  endif
  " if the branch has been deleted, we can find it in pr
  call system("git fetch origin pull/".pr_number."/head:".ref)
  if v:shell_error
    throw "Cannot fetch origin ".ref
  endif
  return [ref, ref]
endfunction


function! s:fetch_pr_data(pr_number)
  let pr_number = a:pr_number
  let cmd = "gh pr view ".pr_number." --json state,mergeCommit,baseRefName,headRefName | jq -r '.baseRefName,.headRefName,.state,.mergeCommit.oid'"
  let output = systemlist(cmd)
  if v:shell_error 
    throw "Cannot find PR for #".pr_number
  endif
  return map(output, 'trim(v:val)')
endfunction

function! s:gh_pr(pr_number, checkout) abort
  echo "Fetching PR information for #".pr_number
  let [baseRefName,headRefName,state,mergeCommit] = s:fetch_pr_data(pr_number)
  echo "Fetching base branch: ".baseRefName
  let baseRefName = s:sync_base_branch(baseRefName)
  if state == "MERGED" && mergeCommit != "null"
    return GitDiffTool(mergeCommit."^", mergeCommit)
  endif
  echo "Fetching ref branch: ".headRefName
  let [headRefName, originHeadRefName] = s:sync_ref_branch(headRefName,pr_number)
  let output = systemlist("git merge-base ".baseRefName." ".originHeadRefName)
  if v:shell_error 
    throw "Cannot find merge-base commit sha for ".baseRefName." and ".headRefName
  endif
  let [merge_base_commit_sha] = output
  " if checkout, compare with current
  if checkout
    call system('git checkout '.headRefName)
    if v:shell_error 
      echohl ErrorMsg 
      echo "Cannot checkout to the branch: ".headRefName
      echohl None
    else
      let originHeadRefName = ''
    endif
  endif
  return GitDiffTool(merge_base_commit_sha, originHeadRefName) 
endfunction

function! GhPrDiffTool(pr_number, checkout=v:false) abort
  let pr_number = a:pr_number
  let checkout = get(a:, 'checkout', v:false)
  if !pr_number
    throw "Missing PR number!"
  endif
  " prefer nvim's async code <from .lua file> 
  if has('nvim')
    return v:lua.GhPr(pr_number, checkout)
  endif

  return s:gh_pr(pr_number, checkout)
endfunction

" support for fzf
function! s:get_pr_number_checkout(str_value)
  let str_value = a:str_value
  let pr_number=""
  let checkout=match(str_value, 'checkout=true') != -1

  if checkout
    let str_value = trim(substitute(str_value, 'checkout=true', '', 'g'))
  endif

  if str_value =~ '^\d\+$'
    let pr_number=str_value
  else 
    let pr_number = matchstr(str_value, '#\zs\d\+')
  endif

  if pr_number == ""
    throw "Missing PR number!"
  endif
  return [pr_number,checkout]
endfunction

" wrapper function for fzf
function! FZFGhPRWrapper(str_value)
  let [pr_number, checkout] = s:get_pr_number_checkout(a:str_value)
  return GhPrDiffTool(pr_number, checkout)
endfunction

function! FZFGhPRs() abort
  call fzf#run(fzf#wrap({
        \ 'source': $FZF_GH_PRS_LIST, 
        \ 'options': $FZF_GH_PRS_LIST_OPTIONS,
        \ 'sink':funcref('FZFGhPRWrapper') 
        \ }))
endfunction

" open pr in web browser
function! GhPrWeb()
  let pr_number = get(g:, 'gh_pr_number', '')
  if pr_number == ''
    echo "Missing PR number"
  endif
  call system('gh pr view -w '.pr_number)
endfunction

command! -nargs=* GhPRDiff call GhPrDiffTool(<f-args>)

nnoremap <silent><leader>gp :call FZFGhPRs()<CR>
nnoremap <silent><leader>go :call GhPrWeb()<CR>
