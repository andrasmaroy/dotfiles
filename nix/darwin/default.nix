{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  nix.package = pkgs.lix;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  system.stateVersion = 7;

  environment.shells = [
    pkgs.fish
    "/opt/homebrew/bin/bash"
  ];

  programs.fish.enable = true;

  fonts.packages = [ (import ../pkgs { inherit pkgs; }).menlo-nerd-font ];

  imports = [
    ./settings.nix
    ./homebrew.nix
  ];
}
