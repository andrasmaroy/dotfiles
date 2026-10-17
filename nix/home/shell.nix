{ config, ... }:
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
  };
}
