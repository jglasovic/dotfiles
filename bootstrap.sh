#!/bin/bash

if ! hash git &> /dev/null; then
	echo "Error: This script requires git! Please install git, then try running this script again." 1>&2;
	exit 1
fi

echo "Installing Jure Glasovic's dotfiles"
echo "Press [ENTER] to proceed, or [CTRL+C] to cancel installation."
read

path="$HOME/.dotfiles"

git clone https://github.com/jglasovic/dotfiles.git "$path"

if [ $? -ne 0 ]; then
  echo "Error: There was a problem cloning the dotfiles repository! Try running this script again." 1>&2;
  exit 1
fi

read -p "Use SSH remote for the dotfiles repository? [y/n] " -e USE_SSH_REMOTE
if [[ $USE_SSH_REMOTE =~ ^[Yy]$ ]]; then
  git -C "$path" remote set-url origin git@github.com:jglasovic/dotfiles.git
fi

"$path"/install.sh
install_exit_code=$?

echo "================================================================================"

if [ $install_exit_code -ne 0 ]; then
	echo "An error occurred during dotfiles installation." 1>&2;
	exit 1
else
	echo "The dotfiles were successfully installed! Enjoy!"
fi
