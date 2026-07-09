{ pkgs, ... }:
let
  # bat theme + syntax, ported from roles/packages/tasks/shell-utilities/bat.yml.
  # The Ansible role downloaded these at apply time and rebuilt the cache; here
  # they are fetched at build time, pinned by upstream commit + content hash
  # (fixed-output derivations), so nothing from other repos is committed and
  # programs.bat rebuilds the cache declaratively.
  tomorrowNightEighties = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/chriskempson/tomorrow-theme/ccf6666d888198d341b26b3a99d0bc96500ad503/textmate/Tomorrow-Night-Eighties.tmTheme";
    sha256 = "daf7079a9382b893f59727304356b4bc8927c9b073120a9fb6879a1af5510fb9";
  };
  themesDir = pkgs.runCommand "bat-theme-tomorrow-night-eighties" { } ''
    mkdir -p $out
    cp ${tomorrowNightEighties} $out/Tomorrow-Night-Eighties.tmTheme
  '';

  plainTasksRaw = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/aziz/PlainTasks/65639252b11d0979bd9c50119a74e2bec07deb80/PlainTasks.sublime-syntax";
    sha256 = "c8cebebf20e99cef007471eba3261383f4c8f48582d1795a39ce7e860485192d";
  };
  # Add uppercase TODO as a recognized extension (was the lineinfile step), so
  # *.TODO files highlight as PlainTasks.
  plainTasksDir = pkgs.runCommand "bat-syntax-plaintasks" { nativeBuildInputs = [ pkgs.gawk ]; } ''
    mkdir -p $out
    gawk '{ print } /^file_extensions:$/ { print "  - TODO" }' ${plainTasksRaw} > $out/PlainTasks.sublime-syntax
  '';
in
{
  # programs.bat is kept only for the machinery: vendoring the theme/syntax and
  # rebuilding the cache. The bat config itself is a raw, editable file under
  # config/ (programs.bat.config is left unset, so it does not manage
  # ~/.config/bat/config and there is no collision with the symlink below).
  programs.bat = {
    enable = true;

    themes."Tomorrow-Night-Eighties" = {
      src = themesDir;
      file = "Tomorrow-Night-Eighties.tmTheme";
    };

    syntaxes."PlainTasks" = {
      src = plainTasksDir;
      file = "PlainTasks.sublime-syntax";
    };
  };

  # Raw editable bat config (in-store).
  home.file.".config/bat/config".source = ../../config/bat/config;
}
