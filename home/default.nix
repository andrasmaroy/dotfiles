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
  imports = [
    ./git.nix
    ./ssh.nix
    ./bat.nix
    ./fzf.nix
  ];

  # Per-user environment.
  #
  # home.username and home.homeDirectory are set by the nix-darwin
  # home-manager module from the enclosing user (see hosts/<name>).

  # Raw dotfiles kept verbatim and symlinked into place (editable in the repo).
  # These are configs that are not fully expressible as home-manager native
  # modules (see the classification table in docs/plans/ansible-to-nix.md).
  home.file = {
    # bash (stays raw: ~400 lines of Homebrew-coupled functions that source
    # each other by literal ~/. paths). Login shell + /etc/shells are handled
    # by nix-darwin, not programs.bash.
    ".bash_colors".source = link "files/bash/bash_colors";
    ".bash_profile".source = link "files/bash/bash_profile";
    ".bash_prompt".source = link "files/bash/bash_prompt";
    ".inputrc".source = link "files/bash/inputrc";

    # Opaque helper scripts and the external private overrides submodule.
    ".bin".source = link "bin";
    ".dotoverrides".source = link "dotoverrides";

    # tmux (version/platform if-shell logic + file sourcing + TPM).
    ".tmux-linux.conf".source = link "files/tmux/tmux-linux.conf";
    ".tmux-osx.conf".source = link "files/tmux/tmux-osx.conf";
    ".tmux.conf".source = link "files/tmux/tmux.conf";

    # vim (submodule plugins + compiled YouCompleteMe + copilot). YCM
    # compilation stays a separate manual step (see plan risks).
    ".ctags".source = link "files/vim/ctags";
    ".gvimrc".source = link "files/vim/gvimrc";
    ".vim".source = link "files/vim/vim";
    ".vimrc".source = link "files/vim/vimrc";
    ".ycm_global_extra_conf".source = link "files/vim/ycm_global_extra_conf";

    # git (hybrid): the executable helper + hook template dir stay raw;
    # gitconfig/ignore/attributes move to programs.git (see home/git.nix).
    ".githelpers".source = link "files/git/githelpers";
    ".git_template".source = link "files/git/git_template";
  };

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

    # roles/vim  (python is shared with dev/python -> single python3)
    cmake
    universal-ctags # was ctags
    python3 # was python
    vim

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
