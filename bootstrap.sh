#!/bin/bash
#
# This script links all configuration files in this repository to their intended place, makes sure necessary basic tools are installed. Operation should be idempotent. On MacOS installs tools and programs defined in the Brewfile and Brewfile-work

set -euo pipefail

if [[ "$(uname -s)" == 'Darwin' ]]; then
  if ! xcode-select --print-path &> /dev/null; then
    xcode-select --install
  fi
fi

readonly GIT_DIR="$(git rev-parse --show-toplevel | sed -e "s:${HOME}/::")"

# Check submodules
if git submodule status | grep '^-' &> /dev/null; then
  echo 'Submodules uninitialized, updating...'
  git submodule update --init --recursive
fi

pip3 install --user pipenv
pipenv install ansible
pipenv run ansible-playbook --connection=local --inventory 127.0.0.1, --ask-become-pass site.yml

if [[ "$(uname -s)" == 'Darwin' ]]; then
  if ! brew tap | grep -q Homebrew/bundle &> /dev/null; then
    echo 'Setting up Homebrew Bundle'
    brew tap Homebrew/bundle
  fi
  echo 'Installing packages from Brewfile'
  brew bundle -f Brewfile
  brew bundle -f Brewfile-work
  if brew list fzf &> /dev/null; then
    /usr/local/opt/fzf/install
  fi
  if command -v vagrant &> /dev/null; then
    if ! vagrant plugin list | grep -qs 'vagrant-vmware-fusion'; then
      vagrant plugin install vagrant-vmware-fusion
      echo 'Vagrant vmware fusion provider installed, setup the license with:'
      echo 'vagrant plugin license vagrant-vmware-fusion ~/license.lic'
    fi
  fi
  brew cleanup
  brew cask cleanup
fi

echo 'Creating necessary folders in ~'
mkdir -p ~/.config
mkdir -p ~/.go
mkdir -p ~/.ssh/{cm_sockets,config.d,keys}
mkdir -p ~/.ssh/keys/{personal,work}

mkdir -p vim/{backup,swap,undo}
chmod 700 vim/{backup,swap,undo}

echo 'Creating symlinks'
ln -isv "../${GIT_DIR}/config/flake8" ~/.config/flake8
ln -isv "../${GIT_DIR}/ssh/config" ~/.ssh/config
ln -isv "${GIT_DIR}/ctags" ~/.ctags
ln -isv "${GIT_DIR}/git_template" ~/.git_template
ln -isv "${GIT_DIR}/gitconfig" ~/.gitconfig
ln -isv "${GIT_DIR}/githelpers" ~/.githelpers
ln -isv "${GIT_DIR}/gitignore_global" ~/.gitignore_global
ln -isv "${GIT_DIR}/gvimrc" ~/.gvimrc
ln -isv "${GIT_DIR}/jshintrc" ~/.jshintrc
ln -isv "${GIT_DIR}/tmux-linux.conf" ~/.tmux-linux.conf
ln -isv "${GIT_DIR}/tmux-osx.conf" ~/.tmux-osx.conf
ln -isv "${GIT_DIR}/tmux.conf" ~/.tmux.conf
ln -isv "${GIT_DIR}/vim" ~/.vim
ln -isv "${GIT_DIR}/vimrc" ~/.vimrc

echo 'Installing YouCompleteMe vim plugin'
pushd vim/pack/functional/start/YouCompleteMe > /dev/null
./install.py --clang-completer --gocode-completer
popd > /dev/null

echo 'Installing python packages'
export PATH="/usr/local/opt/python/libexec/bin:$PATH"
pip install -r requirements.txt
# gem install puppet-lint

if command -v bat &> /dev/null; then
  echo 'Setting up bat theme'
  BAT_CONFIG_DIR="$(bat --config-dir)"
  mkdir -p "$BAT_CONFIG_DIR/themes"
  pushd "$BAT_CONFIG_DIR/themes" > /dev/null
  wget https://raw.githubusercontent.com/chriskempson/tomorrow-theme/master/textmate/Tomorrow-Night-Eighties.tmTheme
  popd > /dev/null

  mkdir -p "$BAT_CONFIG_DIR/syntaxes"
  pushd "$BAT_CONFIG_DIR/syntaxes" > /dev/null
  wget https://raw.githubusercontent.com/aziz/PlainTasks/master/PlainTasks.sublime-syntax
  wget https://raw.githubusercontent.com/alexlouden/Terraform.tmLanguage/master/Terraform.sublime-syntax
  # shellcheck disable=SC1003
  sed -e 's/\(file_extensions:$\)/\1\'$'\n  - TODO/' PlainTasks.sublime-syntax
  popd > /dev/null

  bat cache --build
fi
