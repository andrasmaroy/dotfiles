{ config, pkgs, ... }:
let
  # Absolute path to this repo's working tree at runtime. bootstrap clones to
  # ~/Documents/github/dotfiles; change here if you clone elsewhere. Raw
  # configs are linked from here with mkOutOfStoreSymlink so they stay editable
  # in the working tree (not copied into the Nix store).
  dotfilesDir = "${config.home.homeDirectory}/Documents/github/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/${path}";
in
{
  # Per-user environment.
  #
  # home.username and home.homeDirectory are set by the nix-darwin
  # home-manager module from the enclosing user (see hosts/<name>).

  # Raw dotfiles kept verbatim and symlinked into place (editable in the repo).
  # These are configs that are not fully expressible as home-manager native
  # modules (see the classification table in docs/plans/ansible-to-nix.md).
  # NOTE: sources point at roles/*/files/* for now; Phase 6 (Ansible removal)
  # relocates them under files/ and updates these paths.
  home.file = {
    # roles/bash  (bash stays raw: ~400 lines of Homebrew-coupled functions
    # that source each other by literal ~/. paths). Login shell + /etc/shells
    # are handled by nix-darwin, not programs.bash.
    ".bash_colors".source = link "roles/bash/files/bash_colors";
    ".bash_profile".source = link "roles/bash/files/bash_profile";
    ".bash_prompt".source = link "roles/bash/files/bash_prompt";
    ".inputrc".source = link "roles/bash/files/inputrc";

    # Opaque helper scripts and the external private overrides submodule.
    ".bin".source = link "bin";
    ".dotoverrides".source = link "dotoverrides";

    # roles/tmux  (version/platform if-shell logic + file sourcing + TPM).
    ".tmux-linux.conf".source = link "roles/tmux/files/tmux-linux.conf";
    ".tmux-osx.conf".source = link "roles/tmux/files/tmux-osx.conf";
    ".tmux.conf".source = link "roles/tmux/files/tmux.conf";

    # roles/vim  (submodule plugins + compiled YouCompleteMe + copilot).
    # YCM compilation stays a separate imperative step (see plan risks).
    ".ctags".source = link "roles/vim/files/ctags";
    ".gvimrc".source = link "roles/vim/files/gvimrc";
    ".vim".source = link "roles/vim/files/vim";
    ".vimrc".source = link "roles/vim/files/vimrc";
    ".ycm_global_extra_conf".source = link "roles/vim/files/ycm_global_extra_conf";

    # roles/git (hybrid): the executable helper + hook template dir stay raw;
    # gitconfig/ignore/attributes move to programs.git (see home/git.nix).
    ".githelpers".source = link "roles/git/files/githelpers";
    ".git_template".source = link "roles/git/files/git_template";
  };

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
