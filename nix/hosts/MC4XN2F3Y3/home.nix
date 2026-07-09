{ pkgs, ... }:
{
  # home-manager packages specific to this host (merged with the shared
  # nix/home modules).
  home.packages = with pkgs; [
    awscli2 # AWS CLI v2
    pnpm
    rbenv
    # vaulted is not in nixpkgs -> installed as a Homebrew formula (see
    # default.nix homebrew.brews).
  ];
}
