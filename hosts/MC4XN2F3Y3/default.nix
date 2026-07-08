{ ... }:
let
  username = "andras.maroy";
in
{
  # Apple Silicon.
  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "MC4XN2F3Y3";
  networking.computerName = "MC4XN2F3Y3";
  networking.localHostName = "MC4XN2F3Y3";

  # Owner of this machine; drives sudo/user-scoped defaults.
  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";

  # Attach this user's home-manager configuration.
  home-manager.users.${username} = import ../../home;
}
