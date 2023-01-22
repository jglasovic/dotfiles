#!/bin/sh

SELF_PATH="$( cd "$( dirname "$0" )" && pwd )"

# source utils 
. "$SELF_PATH/zsh.symlink/utils.sh"

# check for brew
if ! command_exists "brew" ; then
  echo "installing brew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "brew has been installed successfully!"
fi

# brew install from Brewfile
echo "Installing brew packages from Brewfile"
brew bundle --file="$SELF_PATH/Brewfile"

# check for oh-my-zsh
if ! check_file_exists "$HOME/.oh-my-zsh/oh-my-zsh.sh" ; then 
  echo "installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo "oh-my-zsh has been successfully instaled!"
fi

# check for rustup
if ! command_exists "rustup" ; then
  echo "installing rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  echo "rustup has been successfully instaled!"
fi

######## Creating symlinks
should_overwrite_all=0
read -p "Do you want to overwrite existing files in your home dirrectory? [y/n] " -e force

if [[ $force =~ ^[Yy]$ ]]; then
  echo "Existing config files will be overwritten!"
  should_overwrite_all=1
else 
  echo "Existing config files will not be overwritten!"
  should_overwrite_all=0
fi


echo "Creating symlinks"
for file in $(find "$SELF_PATH" -maxdepth 1 -name \*.symlink); do
  src_file=$(basename "$file")
  dest_file=$(echo "$HOME/.$src_file" | sed "s/\.symlink$//g")
  if [ -e "$dest_file" ]; then
    if [ "$should_overwrite_all" = "1" ]; then
      rm -rf "$dest_file"
      ln -sv "$SELF_PATH/$src_file" "$dest_file"
    else
      echo "$dest_file already exists; skipping it..."
    fi
  else
    ln -sv "$SELF_PATH/$src_file" "$dest_file"
  fi
done
echo "Config symlinks have been successfully created!"

nvim_src=$SELF_PATH/nvim
nvim_dest=$HOME/.config/nvim

echo "Creating neovim symlinks"
if [ -e "$nvim_dest" ]; then
  if [ "$should_overwrite_all" = "1" ]; then
    rm -rf "$nvim_dest"
    ln -sv "$nvim_src" "$nvim_dest"
  else
    echo "$nvim_dest already exists; skipping it..."
  fi
else
  ln -sv "$nvim_src" "$nvim_dest"
fi
echo "Neovim symlinks have been successfully created!"

# move existing .zshenv in SELF_PATH and create symlink
zshenv_path="$HOME/.zshenv"
self_zshenv_path="$SELF_PATH/.zshenv"
if [ -e "$zshenv_path" ]; then
  cp "$zshenv_path" "$self_zshenv_path"
  rm -r "$zshenv_path"
else
  touch "$self_zshenv_path"
fi
ln -sv "$self_zshenv_path" "$zshenv_path"

## setup tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

## setup zsh
"$SELF_PATH/setup.zsh"





