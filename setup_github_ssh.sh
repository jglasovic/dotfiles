#!/bin/bash

echo "Setup github ssh"
id_ed25519="$HOME/.ssh/id_ed25519"
ssh_config="$HOME/.ssh/config"
ssh_config_content="Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile $id_ed25519"

if [ -f "$id_ed25519" ]; then
  echo "$id_ed25519 file exists!"
else
  read -p "Add your github email: " -e github_email
  if [ -z "$github_email" ]; then
    echo "No github email provided"
    exit 1
  fi
  ssh-keygen -t ed25519 -C "$github_email"
fi
eval "$(ssh-agent -s)"
if [ -f "$ssh_config" ]; then
  echo "$ssh_config file exists!"
  if grep -q "$id_ed25519" "$ssh_config"; then
    echo "$ssh_config file ok!"
  else
    echo "$ssh_config_content" >> "$ssh_config"
  fi
else
  echo "$ssh_config_content" >> "$ssh_config"
fi
echo "$ssh_config has successfully configured!"

macos_ver=12.0
ver=$(sw_vers -productVersion)
if [[ $macos_ver > $ver ]]; then
   ssh-add -K "$id_ed25519"
else
   ssh-add --apple-use-keychain "$id_ed25519"
fi
pbcopy < "$id_ed25519.pub"

echo "Public key is copied into the clipboard.
Add the public key to your Github account under 
SSH and GPG keys in your Settings.
Press y to continue after public key has been added: [y/n] "

sleep 2

open "https://github.com/settings/keys"

read confirm
if [[ $confirm =~ ^[Yy]$ ]]; then
  echo "Gihub ssh setup has successfully finished!"
else 
  echo "Closing github ssh setup"
  exit 1
fi

