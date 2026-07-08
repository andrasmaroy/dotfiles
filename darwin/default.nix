{ pkgs, ... }:
{
  imports = [
    ./homebrew.nix
    ./defaults.nix
    ./activation.nix
  ];

  # Shared system-level configuration applied to every host.

  # Let nix-darwin manage the Nix installation, using Lix as the Nix
  # implementation (bootstrap installs Lix; nix-darwin owns it thereafter).
  nix.package = pkgs.lix;

  # Enable flakes and the new CLI in the managed nix.conf.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # home-manager wiring shared by all users/hosts: reuse the system-wide
  # nixpkgs and install user packages into the user profile.
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # Backwards-compatibility marker; do not bump without reading
  # `darwin-rebuild changelog`.
  system.stateVersion = 5;
}
