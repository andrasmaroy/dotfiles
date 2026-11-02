{
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

      font-family = "Menlo Nerd Font";
      font-size = 13;
      font-thicken = true;
    };
  };
}
