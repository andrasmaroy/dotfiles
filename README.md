# dotfiles

Config files from ~

## Usage

These configuration files are managed with
[nix-darwin](https://github.com/nix-darwin/nix-darwin) and
[home-manager](https://github.com/nix-community/home-manager), pinned with a
Nix flake.

To set up a new machine, run [bootstrap.command](bootstrap.command). It installs
the Xcode Command Line Tools, Rosetta, Homebrew and Nix (Lix), clones this repo
with submodules, and applies the configuration.

Afterwards, to apply changes:

```bash
# Dry run (build only, no changes to the system)
darwin-rebuild build --flake ".#$(scutil --get LocalHostName)"
# Apply
darwin-rebuild switch --flake ".#$(scutil --get LocalHostName)"
```

Each machine is a `darwinConfigurations.<hostname>` entry in
[flake.nix](flake.nix); host-specific settings live in `hosts/<hostname>/`.
Adding a machine means adding that directory and a line in the flake.
