#!/bin/zsh

source "$HOME/.zshrc"

# setup python using pyenv 
py_3=3.9.9
py_2=2.7.11
py_version=$(pyenv version)

if [[ "$py_version" != *"$py_3"* ]]; then
  pyenv install $py_3
  pyenv global $py_3
fi

# check for poetry
if ! command_exists "poetry" ; then
  echo "installing poetry..."
  curl -sSL https://install.python-poetry.org | python3 -
  echo "poetry has been successfully instaled!"
fi

# setup nvm
# add yarn, ts-node, neovim to be installed global for all node versions
# echo "yarn\nts-node\nneovim" > "$HOME/.nvm/default-packages"
# nvm install --lts
# nvm alias default 'lts/*'

# setup neovim py
if ! check_file_exists "$HOME/.pyenv/versions/neovim2/bin/python" ; then
  pyenv install $py_2
  pyenv virtualenv $py_2 neovim2
  pyenv activate neovim2
  pip install neovim
  pyenv deactivate neovim2
fi

if ! check_file_exists "$HOME/.pyenv/versions/neovim3/bin/python" ; then
  pyenv virtualenv $py_3 neovim3
  pyenv activate neovim3
  pip install neovim
  pyenv deactivate neovim3
fi
