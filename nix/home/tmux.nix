{ pkgs, ... }:
let
  # tmux plugin manager (not packaged in nixpkgs' tmuxPlugins set), pinned to
  # the version the Ansible role cloned. The listed plugins (tmux-resurrect,
  # tmux-continuum) install into ~/.tmux/plugins on first launch via prefix + I.
  tpm = pkgs.fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "tpm";
    rev = "v3.0.0";
    hash = "sha256-qYBMDLIEkgiTFxjlF8AHn31HZ4nt/ZoeerzX70SSBaM=";
  };
in
{
  home.packages = with pkgs; [
    tmux
    reattach-to-user-namespace
  ];

  home.file = {
    ".tmux-linux.conf".source = ../../config/tmux/tmux-linux.conf;
    ".tmux-osx.conf".source = ../../config/tmux/tmux-osx.conf;
    ".tmux.conf".source = ../../config/tmux/tmux.conf;
    ".tmux/plugins/tpm".source = tpm;
  };
}
