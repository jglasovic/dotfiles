#!/bin/zsh

source "$HOME/.zshrc"

# remove .profile if exists
if check_file_exists "$HOME/.profile" ; then
  rm -rf "$HOME/.profile"
fi

# check for rustup
if ! command_exists "rustup" ; then
  echo "installing rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  echo "rustup has been successfully instaled!"
fi

# setup python using pyenv 
py_3=3.9.9
py_2=2.7.18
py_version=$(pyenv version)
py_versions=$(pyenv versions)
poetry_version=1.4.2


if [[ "$py_versions" != *"$py_3"* ]]; then
  echo "installing py version $py_3"
  pyenv install $py_3
fi

if [[ "$py_versions" != *"$py_2"* ]]; then
  echo "installing py version $py_2"
  pyenv install $py_2
fi

if [[ "$py_version" != *"$py_3"* ]]; then
  echo "current py version is set to $py_version"
  echo "setting global py version to $py_3"
  pyenv global $py_3
fi

# check for poetry
if ! command_exists "poetry" ; then
  echo "installing poetry..."
  curl -sSL https://install.python-poetry.org | POETRY_VERSION=$poetry_version python3 -
  echo "poetry has been successfully instaled!"
fi

# setup neovim py
if ! check_file_exists "$HOME/.pyenv/versions/neovim2/bin/python" ; then
  echo "setuping neovim py v2 virtualenv"
  pyenv virtualenv $py_2 neovim2
  pyenv activate neovim2
  pip install neovim
  pyenv deactivate neovim2
fi
if ! check_file_exists "$HOME/.pyenv/versions/neovim3/bin/python" ; then
  echo "setuping neovim py v3 virtualenv"
  pyenv virtualenv $py_3 neovim3
  pyenv activate neovim3
  pip3 install neovim
  pyenv deactivate neovim3
fi

