#!/bin/bash
#
# This script links all configuration files in this repository to their intended place, makes sure necessary basic tools are installed. Operation should be idempotent. On MacOS installs tools and programs defined in the Brewfile and Brewfile-work

set -euo pipefail

if [[ "$(uname -s)" == 'Darwin' ]]; then
  if ! xcode-select --print-path &> /dev/null; then
    xcode-select --install
  fi
fi

# Check submodules
if git submodule status | grep '^-' &> /dev/null; then
  echo 'Submodules uninitialized, updating...'
  git submodule update --init --recursive
fi

pip3 install --user pipenv
pipenv install ansible
pipenv run ansible-playbook --connection=local --inventory 127.0.0.1, --ask-become-pass site.yml
