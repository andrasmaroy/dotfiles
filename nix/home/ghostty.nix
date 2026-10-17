{
  pkgs,
  config,
  ...
}:
{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    package = null;
    settings = {
      command = "${config.programs.fish.package}/bin/fish";
    };
  };
}
