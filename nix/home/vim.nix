{ pkgs, ... }:
let
  # Tomorrow-Night-Eighties colorscheme, fetched on build (same upstream repo +
  # commit as the bat theme) and wrapped as a vim runtime dir on the packpath,
  # rather than vendoring the .vim file in this repo.
  tomorrowNightEightiesVim = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/chriskempson/tomorrow-theme/ccf6666d888198d341b26b3a99d0bc96500ad503/vim/colors/Tomorrow-Night-Eighties.vim";
    sha256 = "55e60a0b8d9262b7378866fc7ff61d0ff163b275195a7c178ec417edd549aff7";
  };
  tomorrowColorscheme = pkgs.runCommand "vim-colors-tomorrow-night-eighties" { } ''
    mkdir -p $out/colors
    cp ${tomorrowNightEightiesVim} $out/colors/Tomorrow-Night-Eighties.vim
  '';

  # Not in nixpkgs' vimPlugins set, so build from source (pinned by rev; no
  # hash needed with fetchGit).
  taskpaper-vim = pkgs.vimUtils.buildVimPlugin {
    pname = "taskpaper-vim";
    version = "2df291f";
    src = builtins.fetchGit {
      url = "https://github.com/davidoc/taskpaper.vim";
      ref = "master";
      rev = "2df291f7f40ef049d0a60151c66f11fa21b01e1c";
    };
  };
  vim-polyglot = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-polyglot";
    version = "f061edd";
    src = builtins.fetchGit {
      url = "https://github.com/sheerun/vim-polyglot";
      ref = "master";
      rev = "f061eddb7cdcc614c8406847b2bfb53099832a4e";
    };
  };

  # vim built by Nix with all plugins baked into the packpath. Replaces the raw
  # ~/.vim submodule tree and the manual YouCompleteMe compile: nixpkgs builds
  # YCM (ycm_core/ycmd) and every other plugin, pinned via flake.lock. The old
  # vendored puppet ftplugin/syntax become the maintained vim-puppet plugin.
  # (The niche zainin/vim-mikrotik plugin is intentionally dropped.)
  vim = pkgs.vim-full.customize {
    name = "vim";
    vimrcConfig = {
      customRC = builtins.readFile ../../config/vim/vimrc;
      packages.dotfiles = {
        # Loaded at startup by `packloadall` (was pack/*/start submodules).
        start = (with pkgs.vimPlugins; [
          ale
          copilot-vim
          fzf-vim
          goyo-vim
          typescript-vim
          undotree
          vim-airline-themes
          vim-commentary
          vim-fugitive
          vim-gitgutter
          vim-indexed-search
          vim-puppet
          vim-python-pep8-indent
          vim-surround
          vim-terraform
          YouCompleteMe
        ]) ++ [ tomorrowColorscheme taskpaper-vim vim-polyglot ];
        # Loaded on demand via `packadd! vim-airline` in the vimrc.
        opt = with pkgs.vimPlugins; [ vim-airline ];
      };
    };
  };
in
{
  # gvimrc / ctags / ycm_global_extra_conf remain editable symlinks (see
  # home/default.nix); the vimrc is baked into the build via customRC.
  home.packages = [ vim ];
}
