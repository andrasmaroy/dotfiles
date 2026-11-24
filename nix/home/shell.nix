{ config, pkgs, ... }:
{
  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/Library/Caches/org.freedesktop";
    localBinInPath = true;
  };

  home.sessionVariables = {
    AUTOSSH_POLL = "30";
    EDITOR = "vim";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LS_COLORS = "di=1;34:ln=1;36:so=1;35:pi=33;40:ex=1;32:bd=1;33;40:cd=1;33;40:su=30;43:sg=37;41:tw=37;44:ow=1;35";
    LSCOLORS = "ExGxFxdaCxDADAadhbheFx";
  };

  home.packages = with pkgs; [
    ast-grep
    ctags
    fd
    gh
    gnugrep
    gnused
    ripgrep
    sd
    terminal-notifier
    xh
    yq
  ];
}
