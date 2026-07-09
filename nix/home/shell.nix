{ pkgs, ... }:
{
  # Shell utilities (was roles/packages/tasks/shell-utilities/misc). bat and fzf
  # have their own modules; the completion framework lives with bash.
  home.packages = with pkgs; [
    bandwhich
    coreutils
    fd
    gnused # was gnu-sed
    gnupg
    gnugrep # was grep
    jq
    openssl
    ripgrep
    inetutils # was telnet
    terminal-notifier
    tree
    procps # was watch
    wget
  ];
}
