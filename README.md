# dotfiles

Config files from ~

## Usage

These configuration files are managed with [Ansible](https://www.ansible.com/), to begin a bit of setup is needed:

```bash
pip3 install --user pipenv
pipenv install ansible
```

This assumes Python is installed, and submodules are up to date, for more details see [bootstrap.sh](bootstrap.sh).

Afterwards to apply:
```bash
# For dry run
pipenv run ansible-playbook --check --diff --verbose --connection=local --inventory 127.0.0.1, site.yml
# Actual run
pipenv run ansible-playbook --connection=local --inventory 127.0.0.1, --ask-become-pass site.yml
```
