_:
let
  username = "andras.maroy";
in
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "MC4XN2F3Y3";
  networking.computerName = "MC4XN2F3Y3";

  system.primaryUser = username;
  users.users.${username} = {
    home = "/Users/${username}";
  };

  home-manager = {
    extraSpecialArgs = {
      dotfilesDir = "Documents/github/dotfiles";
    };
    users.${username} = {
      imports = [
        ../../home
      ];
    };
  };
}
