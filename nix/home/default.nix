{ config, dotfilesDir, ... }:
let
  inherit (import ./lib.nix { inherit config dotfilesDir; }) link;
in
{
  home.stateVersion = "26.11";

  home.file = {
    ".bin".source = link "bin";
    ".dotoverrides".source = link "dotoverrides";
  };
}
