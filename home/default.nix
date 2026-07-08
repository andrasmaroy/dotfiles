{ pkgs, ... }:
{
  # Per-user environment.
  #
  # home.username and home.homeDirectory are set by the nix-darwin
  # home-manager module from the enclosing user (see hosts/<name>).

  # CLI packages, ported 1:1 from the Ansible Homebrew formulae, grouped by the
  # role/task they came from (see docs/plans/ansible-to-nix.md). Where the
  # nixpkgs attribute differs from the Homebrew formula name, the original is
  # noted inline.
  home.packages = with pkgs; [
    # roles/bash
    bash

    # roles/git  (dev/tools installs git-delta too -> same `delta`)
    git
    delta # was git-delta

    # roles/ssh
    openssh

    # roles/tmux
    reattach-to-user-namespace
    tmux

    # roles/vim  (python is shared with dev/python -> single python3)
    cmake
    universal-ctags # was ctags
    python3 # was python
    vim

    # packages: install mas (Mac App Store CLI; used by homebrew.masApps)
    mas

    # packages/shell-utilities/bat
    bat

    # packages/shell-utilities/completions
    # brew-cask-completion and pip-completion have no nixpkgs package and stay
    # as homebrew.brews (see darwin/homebrew.nix).
    bash-completion # was bash-completion@2

    # packages/shell-utilities/fzf
    fzf

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

    # packages/dev/python
    black
    flake8
    isort
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
