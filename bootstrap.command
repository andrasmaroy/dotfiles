#!/bin/bash
#
# Bootstrap a machine: install prerequisites (Xcode CLT, Rosetta, Homebrew,
# Nix/Lix), clone this repo, and apply the nix-darwin + home-manager
# configuration. Operation is idempotent; safe to re-run.

set -euo pipefail

if [[ "$(uname -s)" == 'Darwin' ]]; then
  if ! xcode-select --print-path &> /dev/null; then
    xcode-select --install
    while ! xcode-select --print-path &> /dev/null; do
      echo 'Waiting for install to finish...'
      sleep 30
    done
  fi

  /usr/sbin/softwareupdate --install-rosetta --agree-to-license || true
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

# Install Homebrew if missing. nix-darwin's homebrew module manages an
# existing install (casks + Mac App Store apps); it does not install brew.
if [ ! -x /opt/homebrew/bin/brew ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install Nix (Lix) if missing. nix-darwin manages Nix from here on, so use the
# Lix installer rather than the Determinate one (which nix-darwin will not
# manage). The installer enables flakes + the new CLI.
if ! command -v nix &> /dev/null; then
  curl -sSf -L https://install.lix.systems/lix | sh -s -- install
  # Load Nix into the current shell.
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Apply the configuration for this host (darwinConfigurations.<LocalHostName>).
HOST="$(scutil --get LocalHostName)"
readonly HOST
if ! command -v darwin-rebuild &> /dev/null; then
  # First run: bring up nix-darwin itself.
  nix --extra-experimental-features 'nix-command flakes' \
    run nix-darwin -- switch --flake ".#${HOST}"
else
  darwin-rebuild switch --flake ".#${HOST}"
fi
