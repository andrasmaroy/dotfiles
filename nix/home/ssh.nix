{ config, lib, ... }:
let
  home = config.home.homeDirectory;
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    includes = [
      "${home}/.orbstack/ssh/config"
      "config.d/*"
      "${home}/.config/rex/ssh_config"
    ];

    settings = {
      "github.com" = {
        HostName = "ssh.github.com";
        Port = 443;
        User = "git";
        IdentityFile = "${home}/.ssh/keys/personal/id_github";
      };

      "*" = {
        HashKnownHosts = true;
        IdentitiesOnly = true;
        PasswordAuthentication = false;

        AddKeysToAgent = "yes";
        UseKeychain = true;

        ControlMaster = "auto";
        ControlPath = "${home}/.ssh/cm_sockets/%C";
        ControlPersist = "600";
      };
    };
  };

  home.activation.sshDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $VERBOSE_ARG \
      "${home}/.ssh/cm_sockets" \
      "${home}/.ssh/config.d" \
      "${home}/.ssh/keys/personal" \
      "${home}/.ssh/keys/work"
    run chmod 700 $VERBOSE_ARG "${home}/.ssh/cm_sockets"
  '';
}
