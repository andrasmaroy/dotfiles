{ lib, ... }:
{
  # ssh config, ported from roles/ssh/files/config into programs.ssh.
  # First-class options where they exist; the crypto policy (subtraction
  # lists) and a few keywords without HM options go through extraOptions
  # verbatim.
  programs.ssh = {
    enable = true;

    # was: Include config.d/*
    includes = [ "config.d/*" ];

    matchBlocks = {
      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
        identityFile = "~/.ssh/keys/personal/id_github";
      };

      "*" = {
        compression = true;
        hashKnownHosts = true;
        identitiesOnly = true;

        # Reuse existing connections.
        controlMaster = "auto";
        controlPath = "~/.ssh/cm_sockets/%r@%h:%p";
        controlPersist = "600";

        # Pass environment variables for the bash prompt.
        sendEnv = [ "LC_LOGINHOST" "LC_LOGINSYSN" "LC_LOGINUSER" ];

        extraOptions = {
          AddressFamily = "inet";
          PasswordAuthentication = "no";
          Protocol = "2";

          # Prevent client bug CVE-2016-0777, CVE-2016-0778.
          UseRoaming = "no";

          # Disable all the weak crypto (leading '-' subtracts from defaults).
          Ciphers = "-3des-cbc,aes128-cbc,aes192-cbc,aes256-cbc,rijndael-cbc@lysator.liu.se";
          HostKeyAlgorithms = "-ssh-dss,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,ssh-dss-cert-v01@openssh.com,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp521-cert-v01@openssh.com";
          KexAlgorithms = "-diffie-hellman-group1-sha1,diffie-hellman-group14-sha1,diffie-hellman-group14-sha256,diffie-hellman-group-exchange-sha1,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,curve25519-sha256,sntrup4591761x25519-sha512@tinyssh.org";
          MACs = "-hmac-sha1,hmac-sha1-96,hmac-md5,hmac-md5-96,umac-64@openssh.com,hmac-sha1-etm@openssh.com,hmac-sha1-96-etm@openssh.com,hmac-md5-etm@openssh.com,hmac-md5-96-etm@openssh.com,umac-64-etm@openssh.com";
          PubkeyAcceptedKeyTypes = "-ssh-dss,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,ssh-dss-cert-v01@openssh.com,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp521-cert-v01@openssh.com";
        };
      };
    };
  };

  # ssh directory scaffolding (was the "Create ... folder" tasks in
  # roles/ssh). programs.ssh only writes ~/.ssh/config; these dirs still need
  # creating, with cm_sockets locked down to 0700.
  home.activation.sshDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $VERBOSE_ARG \
      "$HOME/.ssh/cm_sockets" \
      "$HOME/.ssh/config.d" \
      "$HOME/.ssh/keys/personal" \
      "$HOME/.ssh/keys/work"
    run chmod 700 $VERBOSE_ARG "$HOME/.ssh/cm_sockets"
  '';
}
