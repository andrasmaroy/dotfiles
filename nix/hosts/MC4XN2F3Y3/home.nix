{ pkgs, ... }:
{
  # home-manager packages specific to this host (merged with the shared
  # nix/home modules).
  home.packages = with pkgs; [
    awscli2 # AWS CLI v2
    granted
    pnpm
    rbenv
  ];
}
