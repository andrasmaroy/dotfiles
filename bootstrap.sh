#!/bin/bash
#
# This script links all configuration files in this repository to their intended place, makes sure necessary basic tools are installed. Operation should be idempotent. On MacOS installs tools and programs defined in the Brewfile and Brewfile-work

set -euo pipefail

if [[ "$(uname -s)" == 'Darwin' ]]; then
  if ! xcode-select --print-path &> /dev/null; then
    xcode-select --install
    while ! xcode-select --print-path &> /dev/null; do
      echo 'Waiting for install to finish...'
      sleep 30
    done
  fi
fi

# Generate SSH key if there isn't one
readonly SSH_KEY_PATH="${HOME}/.ssh/keys/personal/id_github"
if [ ! -f "${SSH_KEY_PATH}" ]; then
  mkdir -p "$(dirname "${SSH_KEY_PATH}")"
  ssh-keygen -f "${SSH_KEY_PATH}" -t ed25519 -N ''
  echo 'Make sure to add the SSH key in Github!'
  cat "${SSH_KEY_PATH}.pub"

   read -n 1 -r -p "Added SSH key in Github? [Y/n] " response
   if [[ ! $response =~ ^[Yy]$ ]] && [[ -n $response ]]; then
     >&2 echo 'Bootstrap aborted.'
     exit 1
   fi
fi

if ! git rev-parse --is-inside-work-tree &> /dev/null; then
 # Clone repo
 mkdir -p "${HOME}/Documents/github"
 cd "${HOME}/Documents/github"
 export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new -i ${SSH_KEY_PATH}"
 git clone --recurse-submodules ssh://git@github.com/andrasmaroy/dotfiles.git
 cd dotfiles
else
  cd "$(git rev-parse --show-toplevel)"
fi

pip3 install --user pipenv

PYTHON_USER_PATH="$(python3 -c 'import site; print(site.USER_BASE)')"
export PATH="${PYTHON_USER_PATH}/bin:${PATH}"
pipenv install
pipenv run ansible-galaxy install -r requirements.yml
pipenv run ansible-playbook --connection=local --inventory 127.0.0.1, --ask-become-pass site.yml
