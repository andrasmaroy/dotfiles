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

## Layout

- [flake.nix](flake.nix) — entry point (stays at the repo root).
- `nix/` — the system configuration: `nix/darwin/` (nix-darwin: packages,
  Homebrew, macOS defaults, activation), `nix/home/` (home-manager), and
  `nix/hosts/<hostname>/` (per-machine settings).
- `config/` — raw, directly-editable app config files (bash, tmux, vim, git,
  ssh, bat, …). Nix symlinks these into place; most are copied into the store,
  so edit the file here and re-run `switch` to apply.
- `bin/`, `dotoverrides/` — scripts and the private overrides submodule,
  symlinked out-of-store (live, not copied into the store).

Each machine is a `darwinConfigurations.<hostname>` entry in
[flake.nix](flake.nix). Adding a machine means adding a `nix/hosts/<hostname>/`
directory and a line in the flake.
