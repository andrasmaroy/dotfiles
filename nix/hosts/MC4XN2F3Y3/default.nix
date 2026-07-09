{ pkgs, ... }:
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
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.bash; # login shell (was set by the bash role)
  };

  # Attach the shared home-manager config plus this host's own module. Both are
  # imported, so their home.packages etc. merge (see home.nix).
  home-manager.users.${username} = {
    imports = [
      ../../home
      ./home.nix
    ];
  };

  # Casks specific to this host (merged with the common set in
  # darwin/homebrew.nix).
  homebrew.casks = [
    "1password"
    "slack"
    "zoom"
  ];

  # vaulted has no nixpkgs package, so it comes from Homebrew here.
  homebrew.brews = [
    "vaulted"
  ];
}
