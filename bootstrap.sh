#!/bin/bash
#
# This script links all configuration files in this repository to their intended place, makes sure necessary basic tools are installed. Operation should be idempotent. On MacOS installs tools and programs defined in the Brewfile and Brewfile-work

set -euo pipefail

readonly GIT_DIR="$(git rev-parse --show-toplevel | sed -e "s:${HOME}/::")"

# Check submodules
if git submodule status | grep '^-' &> /dev/null; then
  echo 'Submodules uninitialized, updating...'
  git submodule update --init --recursive
fi

if [[ "$(uname -s)" == 'Darwin' ]]; then
  if ! which brew &> /dev/null; then
    echo 'Setting up Homebrew'
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
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
  if which vagrant &> /dev/null; then
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

echo 'Creating symlinks'
ln -isv "../${GIT_DIR}/config/flake8" ~/.config/flake8
ln -isv "../${GIT_DIR}/ssh/config" ~/.ssh/config
ln -isv "${GIT_DIR}/bash_colors" ~/.bash_colors
ln -isv "${GIT_DIR}/bash_profile" ~/.bash_profile
ln -isv "${GIT_DIR}/bash_prompt" ~/.bash_prompt
ln -isv "${GIT_DIR}/bin" ~/.bin
ln -isv "${GIT_DIR}/ctags" ~/.ctags
ln -isv "${GIT_DIR}/git_template" ~/.git_template
ln -isv "${GIT_DIR}/gitconfig" ~/.gitconfig
ln -isv "${GIT_DIR}/githelpers" ~/.githelpers
ln -isv "${GIT_DIR}/gitignore_global" ~/.gitignore_global
ln -isv "${GIT_DIR}/gvimrc" ~/.gvimrc
ln -isv "${GIT_DIR}/inputrc" ~/.inputrc
ln -isv "${GIT_DIR}/jshintrc" ~/.jshintrc
ln -isv "${GIT_DIR}/tmux-linux.conf" ~/.tmux-linux.conf
ln -isv "${GIT_DIR}/tmux-osx.conf" ~/.tmux-osx.conf
ln -isv "${GIT_DIR}/tmux.conf" ~/.tmux.conf
ln -isv "${GIT_DIR}/vim" ~/.vim
ln -isv "${GIT_DIR}/vimrc" ~/.vimrc
if [ -d dotoverrides ]; then
  ln -isv "${GIT_DIR}/dotoverrides" ~/.dotoverrides
fi

echo 'Installing YouCompleteMe vim plugin'
pushd vim/bundle/YouCompleteMe > /dev/null
./install.py --clang-completer --gocode-completer
popd > /dev/null

echo 'Installing python packages'
export PATH="/usr/local/opt/python/libexec/bin:$PATH"
pip install -r requirements.txt
# gem install puppet-lint

if [[ "$(uname -s)" == 'Darwin' ]]; then
  touch ~/.bash_sessions_disable
  if ! grep "$(brew --prefix)/bin/bash" /etc/shells > /dev/null; then
    echo 'Adding Homebrewed bash to /etc/shells'
    echo "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells > /dev/null
  fi
  if [[ "$(dscacheutil -q user -a name "${USER}" | grep shell | cut -f 2 -d ' ')" != "$(brew --prefix)/bin/bash" ]]; then
    chsh -s "$(brew --prefix)/bin/bash"
  fi
fi
