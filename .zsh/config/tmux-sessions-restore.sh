#!/bin/sh

# require tmux config json file
function tmux_restore(){
  if ! variable_exists $TMUX_SESSIONS_CONFIG_PATH; then
    echo "You have to set TMUX_SESSIONS_CONFIG_PATH variable"
    return 1
  fi

  local session_list=(`jq -r ".sessions[] | @base64" "$TMUX_SESSIONS_CONFIG_PATH"`)

  for session_encoded in $session_list; do
    local session_decoded=`echo $session_encoded | base64 --decode`
    local session_name=`echo $session_decoded | jq -r ".name"`

    tmux has-session -t $session_name &> /dev/null
    local has_session=$?

    local session_windows=(`echo $session_decoded | jq -r ".windows[] | @base64"`)

    for window_encoded in $session_windows; do
      local window_decoded=`echo $window_encoded | base64 --decode`
      local window_name=`echo $window_decoded | jq -r ".name"`
      local window_path=`echo $window_decoded | jq -r ".path" | tr -d \'\"`
      echo $window_path

      # if session doesn't exist, create it with a first window
      if [[ $has_session != 0 ]]; then
        tmux new-session -d -s $session_name -n $window_name -c $window_path

        has_session=0
        continue
      fi

      # if window doesn't exist, create it
      tmux has_session -t $session_name:$window_name &> /dev/null
      if [[ $? != 0 ]]; then
        tmux new-window -a -n $window_name -t $session_name -c $window_path
      fi

    done
  done

  # pick the last session and attach to it
  local last_session=${session_list[-1]}
  if variable_exists $last_session; then
    local session_decoded=`echo $last_session | base64 --decode`
    local last_session_name=`echo $session_decoded | jq -r ".name"`

    tmux attach -t $last_session_name
  fi
 }
