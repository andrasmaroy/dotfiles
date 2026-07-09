{ config, ... }:
let
  # Out-of-store symlink helper, used only for bin (scripts) and the private
  # dotoverrides submodule, which must NOT be copied into the world-readable
  # Nix store. Everything else is placed in-store by the per-app modules below.
  # bootstrap clones this repo to ~/Documents/github/dotfiles; change here if
  # you clone elsewhere.
  dotfilesDir = "${config.home.homeDirectory}/Documents/github/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/${path}";
in
{
  # Per-app modules own their own package(s), config symlinks and activation.
  imports = [
    ./bash.nix
    ./tmux.nix
    ./git.nix
    ./ssh.nix
    ./fzf.nix
    ./bat.nix
    ./vim.nix
    ./dev.nix
    ./shell.nix
  ];

  # home.username / home.homeDirectory are set by the nix-darwin home-manager
  # module from the enclosing user (see nix/hosts/<name>).

  # Out-of-store symlinks (kept here, not in a module): opaque helper scripts
  # and the external private overrides submodule -- never copied into the store.
  home.file = {
    ".bin".source = link "bin";
    ".dotoverrides".source = link "dotoverrides";
  };

  # Backwards-compatibility marker; do not bump without reading the
  # home-manager release notes.
  home.stateVersion = "25.05";
}
