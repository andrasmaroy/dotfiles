{ ... }:
{
  # Shared system-level configuration applied to every host.

  # Enable flakes and the new CLI (also enabled globally by the Determinate
  # installer, but set here so a plain Nix install works too).
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # home-manager wiring shared by all users/hosts: reuse the system-wide
  # nixpkgs and install user packages into the user profile.
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # Backwards-compatibility marker; do not bump without reading
  # `darwin-rebuild changelog`.
  system.stateVersion = 5;
}
