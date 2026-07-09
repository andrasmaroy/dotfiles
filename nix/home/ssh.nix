{ lib, pkgs, ... }:
{
  home.packages = [ pkgs.openssh ];

  # Raw ssh config; programs.ssh is not used. The config.d / keys / cm_sockets
  # directories still need creating (cm_sockets locked to 0700).
  home.file.".ssh/config".source = ../../config/ssh/config;

  home.activation.sshDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $VERBOSE_ARG \
      "$HOME/.ssh/cm_sockets" \
      "$HOME/.ssh/config.d" \
      "$HOME/.ssh/keys/personal" \
      "$HOME/.ssh/keys/work"
    run chmod 700 $VERBOSE_ARG "$HOME/.ssh/cm_sockets"
  '';
}
