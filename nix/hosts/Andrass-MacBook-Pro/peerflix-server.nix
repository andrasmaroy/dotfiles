{ pkgs, ... }:

let
  peerflix-server-native = (import ../../pkgs { inherit pkgs; }).peerflix-server;
in
{
  environment.systemPackages = [ peerflix-server-native ];

  launchd.user.agents.peerflix-server = {
    script = ''
      mkdir -p /tmp/torrent-stream
      touch /tmp/peerflix-server.out.log /tmp/peerflix-server.err.log
      exec ${peerflix-server-native}/bin/peerflix-server
    '';
    serviceConfig = {
      WorkingDirectory = "${peerflix-server-native}/lib/node_modules/peerflix-server";
      EnvironmentVariables = {
        "HOME" = "/tmp/torrent-stream";
      };
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/peerflix-server.out.log";
      StandardErrorPath = "/tmp/peerflix-server.err.log";
    };
  };
}
