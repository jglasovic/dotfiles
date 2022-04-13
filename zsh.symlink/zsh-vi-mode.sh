# source zshrc fix
bindkey -v

# protect from sourcing zshrc multiple times
if ! variable_exists $ZVM_LOADED; then
  ZVM_LOADED=true
  # ZVM_READKEY_ENGINE=$ZVM_READKEY_ENGINE_ZLE

  zle_highlight+=(paste:none)

  function custom_put_replace_selection(){
    zvm_highlight clear
    zle .put-replace-selection "$@"
    zvm_yank
    echo "$CUTBUFFER" | pbcopy
    zvm_select_vi_mode $ZVM_MODE_NORMAL true
  }

  zle -N put_replace_selection custom_put_replace_selection

  # overriding some functions, cannot use .function for these
  functions[_zvm_vi_yank]=$functions[zvm_vi_yank]
  functions[_zvm_vi_put_after]=$functions[zvm_vi_put_after]
  functions[_zvm_vi_put_before]=$functions[zvm_vi_put_before]
  functions[_zvm_vi_delete]=$functions[zvm_vi_delete]

  # use system clipboard
  function pbpaste_to_cutbuffer() {
    CUTBUFFER=`pbpaste -Prefer txt`;
  }

  function pbcopy_cutbuffer() {
    echo "$CUTBUFFER" | pbcopy
  }

  function zvm_vi_yank() {
    _zvm_vi_yank "$@"
    pbcopy_cutbuffer
  }

  function zvm_vi_delete() {
    zvm_highlight clear
    _zvm_vi_delete "$@"
    pbcopy_cutbuffer
  }

  function zvm_vi_put_after(){
    pbpaste-to-cutbuffer
    _zvm_vi_put_after "$@"
    zvm_highlight clear
  }

  function zvm_vi_put_before(){
    pbpaste-to-cutbuffer
    _zvm_vi_put_before "$@"
    zvm_highlight clear
  }

  # keybindings
  bindkey -M vicmd 'H' beginning-of-line
  bindkey -M vicmd 'L' end-of-line

  bindkey -M vicmd 'k' up-line-or-beginning-search
  bindkey -M vicmd 'j' down-line-or-beginning-search

  bindkey -M vicmd '^[[A' up-line-or-beginning-search
  bindkey -M vicmd '^[[B' down-line-or-beginning-search
  bindkey -M viins '^[[A' up-line-or-beginning-search
  bindkey -M viins '^[[B' down-line-or-beginning-search

  bindkey -M visual 'p' put_replace_selection

fi




