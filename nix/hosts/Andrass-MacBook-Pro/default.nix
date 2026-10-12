{ pkgs, ... }:
let
  username = "andrasmaroy";
in
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "Andrass-MacBook-Pro";
  networking.computerName = "András’s MacBook Pro";

  system.primaryUser = username;
  users.users.${username} = {
    home = "/Users/${username}";
  };

  home-manager.extraSpecialArgs = {
    dotfilesDir = "Documents/github/dotfiles";
  };

  imports = [
    ./peerflix-server.nix
  ];
}
