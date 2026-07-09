{ pkgs, ... }:
{
  imports = [
    ./homebrew.nix
    ./defaults.nix
    ./activation.nix
  ];

  # Shared system-level configuration applied to every host.

  # Allow unfree packages (e.g. the copilot.vim plugin, which is GitHub
  # Copilot). Tighten to an allowUnfreePredicate if a narrower policy is wanted.
  nixpkgs.config.allowUnfree = true;

  # Let nix-darwin manage the Nix installation, using Lix as the Nix
  # implementation (bootstrap installs Lix; nix-darwin owns it thereafter).
  nix.package = pkgs.lix;

  # Enable flakes and the new CLI in the managed nix.conf.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # home-manager wiring shared by all users/hosts: reuse the system-wide
  # nixpkgs and install user packages into the user profile.
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # Register the (nixpkgs) bash as a valid login shell in /etc/shells; the
  # per-user login shell is set in the host module. Was the /etc/shells +
  # chsh steps in the bash role (Homebrew bash is no longer installed).
  environment.shells = [ pkgs.bash ];

  # Backwards-compatibility marker; do not bump without reading
  # `darwin-rebuild changelog`.
  system.stateVersion = 5;
}
