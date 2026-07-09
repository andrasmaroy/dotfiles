{ config, lib, pkgs, ... }:
let
  # Out-of-store symlink helper, used only for bin (scripts) and the private
  # dotoverrides submodule, which must NOT be copied into the world-readable
  # Nix store. Everything else is placed in-store (see config/ symlinks below).
  # bootstrap clones this repo to ~/Documents/github/dotfiles; change here if
  # you clone elsewhere.
  dotfilesDir = "${config.home.homeDirectory}/Documents/github/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/${path}";

  # tmux plugin manager. Not packaged in nixpkgs' tmuxPlugins set, so fetch it
  # directly, pinned to the version the Ansible role cloned.
  tpm = pkgs.fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "tpm";
    rev = "v3.0.0";
    hash = "sha256-qYBMDLIEkgiTFxjlF8AHn31HZ4nt/ZoeerzX70SSBaM=";
  };
in
{
  imports = [
    ./git.nix
    ./ssh.nix
    ./bat.nix
    ./fzf.nix
    ./vim.nix
  ];

  # Per-user environment.
  #
  # home.username and home.homeDirectory are set by the nix-darwin
  # home-manager module from the enclosing user (see hosts/<name>).

  # Raw config files, kept verbatim under config/ and symlinked into place.
  # These are placed in-store (source = ../../config/...) so they are pinned in
  # the closure; edit the repo file and `darwin-rebuild switch` to apply. bin
  # and dotoverrides are the out-of-store exceptions (see `link` above).
  home.file = {
    # bash (raw: ~400 lines of Homebrew-coupled functions that source each
    # other by literal ~/. paths). Login shell + /etc/shells are handled by
    # nix-darwin, not programs.bash.
    ".bash_colors".source = ../../config/bash/bash_colors;
    ".bash_profile".source = ../../config/bash/bash_profile;
    ".bash_prompt".source = ../../config/bash/bash_prompt;
    ".inputrc".source = ../../config/bash/inputrc;

    # Opaque helper scripts and the external private overrides submodule --
    # out-of-store (never copied into /nix/store).
    ".bin".source = link "bin";
    ".dotoverrides".source = link "dotoverrides";

    # tmux (version/platform if-shell logic + file sourcing + TPM).
    ".tmux-linux.conf".source = ../../config/tmux/tmux-linux.conf;
    ".tmux-osx.conf".source = ../../config/tmux/tmux-osx.conf;
    ".tmux.conf".source = ../../config/tmux/tmux.conf;

    # vim is built by Nix (see vim.nix); the vimrc lives in config/vim/vimrc and
    # is pulled in via customRC. These extra bits stay raw.
    ".ctags".source = ../../config/vim/ctags;
    ".gvimrc".source = ../../config/vim/gvimrc;
    ".ycm_global_extra_conf".source = ../../config/vim/ycm_global_extra_conf;

    # git: the executable helper + hook template dir (config/git/config and the
    # ssh config become raw files in later restructure phases).
    ".githelpers".source = ../../config/git/githelpers;
    ".git_template".source = ../../config/git/git_template;

    # flake8 config (was symlinked to ~/.config/flake8 by the python role).
    ".config/flake8".source = ../../config/flake8;

    # tmux plugin manager (was a git clone in the tmux role). The listed
    # plugins (tmux-resurrect, tmux-continuum) install into ~/.tmux/plugins on
    # first launch via prefix + I.
    ".tmux/plugins/tpm".source = tpm;
  };

  # Runtime directories the raw configs expect (were mkdir tasks in the bash
  # and vim roles). ~/.vim is a symlink into the repo, so the vim dirs land
  # there, exactly as before.
  home.activation.runtimeDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $VERBOSE_ARG "$HOME/Library/Caches/org.freedesktop"
    run mkdir -p $VERBOSE_ARG "$HOME/.vim/backup" "$HOME/.vim/swap" "$HOME/.vim/undo"
    run chmod 700 $VERBOSE_ARG "$HOME/.vim/backup" "$HOME/.vim/swap" "$HOME/.vim/undo"
  '';

  # CLI packages, ported 1:1 from the Ansible Homebrew formulae, grouped by the
  # role/task they came from (see docs/plans/ansible-to-nix.md). Where the
  # nixpkgs attribute differs from the Homebrew formula name, the original is
  # noted inline.
  home.packages = with pkgs; [
    # roles/bash
    bash

    # roles/git  (git itself is installed by programs.git in home/git.nix;
    # delta stays here since git.nix wires delta by hand, not via delta.enable)
    delta # was git-delta

    # roles/ssh
    openssh

    # roles/tmux
    reattach-to-user-namespace
    tmux

    # roles/vim  (vim itself is built by Nix in home/vim.nix; cmake was only
    # needed to compile YouCompleteMe, which nixpkgs now builds)
    universal-ctags # was ctags
    python3 # was python (shared with dev/python)

    # packages: install mas (Mac App Store CLI; used by homebrew.masApps)
    mas

    # packages/shell-utilities/bat -> installed by programs.bat (home/bat.nix)

    # packages/shell-utilities/completions
    # brew-cask-completion and pip-completion have no nixpkgs package and stay
    # as homebrew.brews (see darwin/homebrew.nix).
    bash-completion # was bash-completion@2

    # packages/shell-utilities/fzf -> installed by programs.fzf (home/fzf.nix)

    # packages/shell-utilities/misc
    bandwhich
    coreutils
    fd
    gnused # was gnu-sed
    gnupg
    gnugrep # was grep
    jq
    openssl
    ripgrep
    inetutils # was telnet
    terminal-notifier
    tree
    procps # was watch
    wget

    # packages/dev/javascript
    nodejs # was node
    typescript

    # packages/dev/linters
    shellcheck

    # packages/dev/python  (flake8/isort are not top-level attrs)
    black
    python3Packages.flake8
    python3Packages.isort
    pipenv
    python3Packages.setuptools # was python-setuptools
    python3Packages.virtualenvwrapper

    # packages/dev/tools  (docker-completion has no nixpkgs package -> brews)
    gh
    kubernetes-helm # was helm
    kubectl
  ];

  # Backwards-compatibility marker; do not bump without reading the
  # home-manager release notes.
  home.stateVersion = "25.05";
}
