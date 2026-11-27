{ config, lib, ... }:
let
  systemCasks = [
    "canon-eos-utility"
    "firefox"
  ];

  userCasks = [
    "appcleaner"
    "disk-inventory-x"
    "ghostty"
    "itsycal"
    "jordanbaird-ice"
    "keepingyouawake"
    "linearmouse"
    "logseq"
    "monitorcontrol"
    "orbstack"
    "p4v"
    "rectangle"
  ];

  inUserApps = name: {
    inherit name;
    args.appdir = "~/Applications";
  };
in
{
  environment.variables = lib.mkIf config.homebrew.enable {
    HOMEBREW_NO_ANALYTICS = "1";
    HOMEBREW_NO_GITHUB_API = "1";
    HOMEBREW_NO_INSTALL_UPGRADE = "1";
  };

  homebrew = {
    enable = true;
    enableFishIntegration = true;

    casks = systemCasks ++ map inUserApps userCasks;

    onActivation = {
      autoUpdate = false;
      cleanup = "none";
      extraEnv = {
        HOMEBREW_NO_ANALYTICS = "1";
        HOMEBREW_NO_GITHUB_API = "1";
        HOMEBREW_NO_INSTALL_UPGRADE = "1";
      };
      upgrade = true;
    };
  };
}
