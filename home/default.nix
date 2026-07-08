{ ... }:
{
  # Per-user environment. Intentionally minimal during the skeleton phase;
  # CLI packages and dotfiles land here in later phases of the
  # ansible-to-nix migration (see docs/plans/ansible-to-nix.md).

  # home.username and home.homeDirectory are set by the nix-darwin
  # home-manager module from the enclosing user (see hosts/<name>).

  # Backwards-compatibility marker; do not bump without reading the
  # home-manager release notes.
  home.stateVersion = "25.05";
}
