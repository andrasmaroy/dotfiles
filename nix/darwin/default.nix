{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  nix.package = pkgs.lix;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  system.stateVersion = 7;

  imports = [
    ./settings.nix
  ];
}
