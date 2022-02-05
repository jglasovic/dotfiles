#!/bin/sh

source ~/.zsh/utils.sh

function tmux_sessions_restore(){
  if ! variable_exists $TMUX_SESSIONS_PATH; then
    echo "You have to set TMUX_SESSIONS_PATH variable"
    return 1
  fi

  local session_list=("${(@s/:/)TMUX_SESSIONS_PATH}")

  for session in $session_list; do
    # using eval to properly parse path for `find` command bellow
    local session_path=`eval "echo $session | xargs"`
    local session_name=`basename $session_path`

    tmux has-session -t $session_name &> /dev/null
    local has_session=$?

    for window in `find $session_path -type d -mindepth 1 -maxdepth 1`; do
      local window_name=`basename $window`

      # ignore windows defined in TMUX_IGNORE_WIN variable
      if variable_exists $TMUX_IGNORE_WIN && [[ $TMUX_IGNORE_WIN =~ $window_name ]]; then
        continue
      fi

      # if session doesn't exist, create it with a first window
      if [[ $has_session != 0 ]]; then
        tmux new-session -d -s $session_name -n $window_name -c $window

        has_session=0
        continue
      fi

      # if window doesn't exist, create it
      tmux has_session -t $session_name:$window_name &> /dev/null
      if [[ $? != 0 ]]; then
        tmux new-window -a -n $window_name -t $session_name -c $window
      fi

    done
  done

  # pick the last session and attach to it
  local last_session=${session_list[-1]}
  if variable_exists $last_session; then
    local last_session_name=`basename $last_session`
    tmux attach -t $last_session_name
  fi
 }
