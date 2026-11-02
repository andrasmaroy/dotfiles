{ pkgs }:
{
  menlo-nerd-font = pkgs.callPackage ./menlo-nerd-font.nix { };
  peerflix-server = pkgs.callPackage ./peerflix-server.nix { };
}
