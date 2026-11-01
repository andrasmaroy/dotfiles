{ pkgs }:
{
  peerflix-server = pkgs.callPackage ./peerflix-server.nix { };
}
