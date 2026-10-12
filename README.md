# dotfiles

Config files from ~

## Usage

These configuration files are managed with [Ansible](https://www.ansible.com/), to begin a bit of setup is needed:

```bash
pip3 install --user pipenv
pipenv install
pipenv run ansible-galaxy collection install community.general

# nix
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

This assumes Python is installed, and submodules are up to date, for more details see [bootstrap.sh](bootstrap.sh).

Afterwards to apply:
```bash
# For dry run
pipenv run ansible-playbook --check --diff --verbose --connection=local --inventory 127.0.0.1, site.yml
darwin-rebuild build --flake ".#$(scutil --get LocalHostName)"
# Actual run
pipenv run ansible-playbook --connection=local --inventory 127.0.0.1, --ask-become-pass site.yml
sudo darwin-rebuild switch --flake ".#$(scutil --get LocalHostName)"
```
