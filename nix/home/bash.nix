{ lib, pkgs, ... }:
{
  # bash: raw config kept out of programs.bash (the files source each other by
  # literal ~/. paths), plus the completion framework. The login shell and
  # /etc/shells are handled by nix-darwin, not here.
  home.packages = with pkgs; [
    bash
    bash-completion # was bash-completion@2
  ];

  home.file = {
    ".bash_colors".source = ../../config/bash/bash_colors;
    ".bash_profile".source = ../../config/bash/bash_profile;
    ".bash_prompt".source = ../../config/bash/bash_prompt;
    ".inputrc".source = ../../config/bash/inputrc;
  };

  # Cache dir the shell expects (was a mkdir in the bash role).
  home.activation.freedesktopCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $VERBOSE_ARG "$HOME/Library/Caches/org.freedesktop"
  '';
}
