{ config, dotfilesDir }:
{
  link =
    path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${dotfilesDir}/${path}";
}
