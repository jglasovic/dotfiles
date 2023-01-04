#!/bin/zsh

source "$HOME/.zshrc"

# setup python using pyenv 
pyenv install 3.9.9
pyenv global 3.9.9

# check for poetry
if ! command_exists "poetry" ; then
  echo "installing poetry..."
  curl -sSL https://install.python-poetry.org | python3 -
  echo "poetry has been successfully instaled!"
fi

# setup nvm
# add yarn, ts-node, neovim to be installed global for all node versions
echo "yarn\nts-node\nneovim" > "$HOME/.nvm/default-packages"
nvm install --lts
nvm alias default 'lts/*'

# setup neovim py
if ! check_file_exists "$HOME/.pyenv/versions/neovim2/bin/python" ; then
  pyenv install 2.7.11
  pyenv virtualenv 2.7.11 neovim2
  pyenv activate neovim2
  pip install neovim
  pyenv deactivate neovim2
fi

if ! check_file_exists "$HOME/.pyenv/versions/neovim3/bin/python" ; then
  pyenv virtualenv 3.9.9 neovim3
  pyenv activate neovim3
  pip install neovim
  pyenv deactivate neovim3
fi
