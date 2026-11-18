{ config, lib, ... }:
{
  environment.variables = lib.mkIf config.homebrew.enable {
    HOMEBREW_NO_GITHUB_API = "1";
    HOMEBREW_NO_INSTALL_UPGRADE = "1";
  };

  homebrew = {
    enable = true;
    enableFishIntegration = true;

    casks = [
      "ghostty"
    ];
  };
}
