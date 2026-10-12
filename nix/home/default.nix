{ config, dotfilesDir, ... }:
let
  link =
    path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${dotfilesDir}/${path}";
in
{
  home.stateVersion = "26.11";

  home.file = {
    ".bin".source = link "bin";
    ".dotoverrides".source = link "dotoverrides";
  };
}
