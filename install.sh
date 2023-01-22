#!/bin/bash

SELF_PATH="$( cd "$( dirname "$0" )" && pwd )"

source "$SELF_PATH/.zsh/utils.sh"

# check for brew
if ! type "brew" &> /dev/null; then
  echo "installing brew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "brew has been installed successfully!"
fi

# brew install from Brewfile
echo "Installing brew packages from Brewfile"
brew bundle --file="$SELF_PATH/Brewfile"

# check for oh-my-zsh
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then 
  echo "installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo "oh-my-zsh has been successfully instaled!"
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

if [ ! -f "$SELF_PATH/.zshenv" ]; then
  touch "$SELF_PATH/.zshenv"
fi

echo "Creating symlinks"
nvim_src="$SELF_PATH/nvim"
nvim_dest="$HOME/.config/nvim"

vim_src="$SELF_PATH/.vim"
vim_dest="$HOME/.vim"

zsh_src="$SELF_PATH/.zsh"
zsh_dest="$HOME/.zsh"

zshrc_src="$SELF_PATH/.zshrc"
zshrc_dest="$HOME/.zshrc"

zshenv_src="$SELF_PATH/.zshenv"
zshenv_dest="$HOME/.zshenv"

gitconfig_src="$SELF_PATH/.gitconfig"
gitconfig_dest="$HOME/.gitconfig"

gitignore_global_src="$SELF_PATH/.gitignore_global"
gitignore_global_dest="$HOME/.gitignore_global"

tmux_conf_src="$SELF_PATH/.tmux.conf"
tmux_conf_dest="$HOME/.tmux.conf"

set_symlink "$nvim_src" "$nvim_dest" "$should_overwrite_all" 
set_symlink "$vim_src" "$vim_dest" "$should_overwrite_all" 
set_symlink "$zsh_src" "$zsh_dest" "$should_overwrite_all" 
set_symlink "$zshrc_src" "$zshrc_dest" "$should_overwrite_all" 
set_symlink "$zshenv_src" "$zshenv_dest" "$should_overwrite_all" 
set_symlink "$gitconfig_src" "$gitconfig_dest" "$should_overwrite_all" 
set_symlink "$gitignore_global_src" "$gitignore_global_dest" "$should_overwrite_all" 
set_symlink "$tmux_conf_src" "$tmux_conf_dest" "$should_overwrite_all" 

## setup tmux plugin manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ] || [ "$should_overwrite_all" = "1" ]; then
    rm -rf "$HOME/.tmux/plugins/tpm"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

## setup github ssh
"$SELF_PATH/setup_github_ssh.sh"

## setup zsh
"$SELF_PATH/setup.zsh"
