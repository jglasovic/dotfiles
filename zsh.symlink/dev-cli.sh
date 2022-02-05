#!/bin/sh
source ~/.zsh/utils.sh
source ~/.zsh/vpn-connection-check.sh

# aws credentials expiration
function get-aws-ceredentials-expiration(){
  local aws_credentials_path=~/.aws/credentials
  if check-file-exists $aws_credentials_path ; then
    local x_security_token_expires=$1
    while IFS=' = ' read key value
    do
      if [[ $key == \[*] ]]; then
        section=$key
      elif [[ $value ]] && [[ $section == '[default]' ]]; then
        if [[ $key == 'x_security_token_expires' ]]; then
          eval $x_security_token_expires=$value
        fi
      fi
    done < $aws_credentials_path
  else
    exit "Missing $aws_credentials_path"
  fi
}


function load-dev-cli() {
  if ! variable_exists $PROJECT_DIR; then
    return 1
  fi

  for dir in $(find $PROJECT_DIR -mindepth 1 -maxdepth 1 -type d); do
    if [[ "$PWD" == "$dir" ]]; then
      get-aws-ceredentials-expiration aws_expiration_date
      local aws_expiration_date_formated=$(date -d $aws_expiration_date +%s)
      local date_now_formated=$(date +%s)

      if [[ $aws_expiration_date_formated -lt $date_now_formated ]]; then
        check-vpn-connection
        saml2aws login
        dev-cli configure --code-artifact
      else
         print-red "AWS - credentials are not expired, skipping!"
      fi
    fi
  done
}
