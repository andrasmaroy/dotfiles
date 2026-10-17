{ config, dotfilesDir, ... }:
let
  inherit (import ./lib.nix { inherit config dotfilesDir; }) link;
in
{
  home.stateVersion = "26.11";

  home.file = {
    ".dotoverrides".source = link "dotoverrides";
    ".local/bin".source = link "bin";
  };

  imports = [
    ./shell.nix
    ./fish.nix
    ./ghostty.nix
    ./atuin.nix
    ./zoxide.nix
    ./mise.nix
    ./fzf.nix
  ];
}
